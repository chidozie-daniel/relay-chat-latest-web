using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Security;
using System.Web.UI;
using RelayChat.Web.Common;
using RelayChat.Web.Data.Repositories;
using RelayChat.Web.Models;

namespace RelayChat.Web
{
    /// <summary>
    /// Main chat workspace. Inherits SecurePage — auth guard runs before
    /// Page_Load, guaranteeing CurrentUser is always populated.
    /// </summary>
    public partial class Chat : SecurePage
    {
        /* ── State exposed to the markup repeaters ──────────────────── */
        public int  SelectedConversationId { get; private set; }
        public int  SelectedChannelId      { get; private set; }
        public bool IsChannel              { get; private set; }

        /* ── ViewState key for thread context ───────────────────────── */
        private int ThreadParentMessageId
        {
            get => ViewState["ThreadParentMessageId"] != null ? (int)ViewState["ThreadParentMessageId"] : 0;
            set => ViewState["ThreadParentMessageId"] = value;
        }

        /* ── Repositories (composed per-request) ────────────────────── */
        private readonly IConversationRepository _convos    = new ConversationRepository();
        private readonly IChannelRepository      _channels  = new ChannelRepository();
        private readonly IMessageRepository      _messages  = new MessageRepository();
        private readonly IUserRepository         _users     = new UserRepository();
        private readonly IReactionRepository     _reactions = new ReactionRepository();
        private readonly IAuditLogRepository     _auditLogs = new AuditLogRepository();

        /* ── Page lifecycle ─────────────────────────────────────────── */
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindCurrentUser();
                BindRail();
                BindNotifications();
                tmrRefresh.Enabled = false;
            }
        }

        private void BindCurrentUser()
        {
            hfCurrentUserId.Value       = CurrentUser.UserId.ToString();
            hfCurrentUserName.Value     = CurrentUser.DisplayName;
            hfCurrentUserInitials.Value = CurrentUser.GetInitials();
            hfCurrentUserColor.Value    = CurrentUser.GetAvatarColor();
            hfCurrentUserRole.Value     = CurrentUser.Role;

            litFooterName.Text    = System.Web.HttpUtility.HtmlEncode(CurrentUser.DisplayName);
            litFooterAvatar.Text  = $@"<div class=""avatar"" style=""width:36px;height:36px;background:{CurrentUser.GetAvatarColor()};font-size:.85rem;"">{CurrentUser.GetInitials()}</div>";
            lnkAdmin.Visible      = CurrentUser.Role == "Administrator";

            // Pre-fill settings fields
            txtSetDisplayName.Text = CurrentUser.DisplayName;
            txtSetStatus.Text      = CurrentUser.StatusMessage ?? "";
        }

        /* ── Rail binding ───────────────────────────────────────────── */
        private void BindRail()
        {
            // DMs
            var convos = _convos.GetByUser(CurrentUser.UserId);
            var dmItems = convos.Select(c =>
            {
                var other = c.UserAId == CurrentUser.UserId ? c.UserB : c.UserA;
                var msgs  = _messages.GetByConversation(c.ConversationId);
                var last  = msgs.LastOrDefault();
                // Unread = messages from others that are newer than last-seen
                int unread = msgs.Count(m => m.SenderUserId != CurrentUser.UserId && !m.IsRead);
                return new
                {
                    ConversationId     = c.ConversationId,
                    OtherUser          = other,
                    LastMessageTime    = last != null ? last.GetFormattedTime() : "",
                    LastMessagePreview = last != null ? TruncatePreview(last.GetDisplayBody()) : "No messages yet",
                    UnreadCount        = unread
                };
            }).ToList();
            rptDMs.DataSource = dmItems;
            rptDMs.DataBind();

            // Channels
            var channels = _channels.GetByMember(CurrentUser.UserId);
            var chItems = channels.Select(ch =>
            {
                var msgs  = _messages.GetByChannel(ch.ChannelId);
                var last  = msgs.LastOrDefault();
                int unread = msgs.Count(m => m.SenderUserId != CurrentUser.UserId && !m.IsRead);
                return new
                {
                    ChannelId          = ch.ChannelId,
                    Name               = ch.Name,
                    Icon               = ch.Icon ?? "💬",
                    LastMessageTime    = last != null ? last.GetFormattedTime() : "",
                    LastMessagePreview = last != null ? TruncatePreview(last.GetDisplayBody()) : "No messages yet",
                    UnreadCount        = unread
                };
            }).ToList();
            rptChannels.DataSource = chItems;
            rptChannels.DataBind();
        }

        private static string TruncatePreview(string s) =>
            s.Length > 60 ? s.Substring(0, 57) + "…" : s;

        /* ── Notification binding ────────────────────────────────────── */
        private void BindNotifications()
        {
            // Pull recent unread messages addressed to the current user from
            // conversations and channels they're a member of.
            var notifItems = new List<object>();

            // DM notifications
            foreach (var c in _convos.GetByUser(CurrentUser.UserId))
            {
                var msgs = _messages.GetByConversation(c.ConversationId)
                    .Where(m => m.SenderUserId != CurrentUser.UserId && !m.IsRead)
                    .OrderByDescending(m => m.SentAt)
                    .Take(3);
                var other = c.UserAId == CurrentUser.UserId ? c.UserB : c.UserA;
                foreach (var m in msgs)
                {
                    notifItems.Add(new
                    {
                        FromName       = other?.DisplayName ?? "Someone",
                        SenderInitials = other?.GetInitials() ?? "?",
                        SenderColor    = other?.GetAvatarColor() ?? "#5B5FEF",
                        PreviewText    = TruncatePreview(m.GetDisplayBody()),
                        TimeAgo        = GetTimeAgo(m.SentAt),
                        IsRead         = false,
                        ConvoType      = "dm",
                        ConvoId        = c.ConversationId.ToString()
                    });
                }
            }

            // Channel notifications
            foreach (var ch in _channels.GetByMember(CurrentUser.UserId))
            {
                var msgs = _messages.GetByChannel(ch.ChannelId)
                    .Where(m => m.SenderUserId != CurrentUser.UserId && !m.IsRead)
                    .OrderByDescending(m => m.SentAt)
                    .Take(2);
                foreach (var m in msgs)
                {
                    var sender = m.Sender;
                    notifItems.Add(new
                    {
                        FromName       = "#" + ch.Name,
                        SenderInitials = sender?.GetInitials() ?? "?",
                        SenderColor    = sender?.GetAvatarColor() ?? "#5B5FEF",
                        PreviewText    = (sender?.DisplayName?.Split(' ')[0] ?? "Someone") + ": " + TruncatePreview(m.GetDisplayBody()),
                        TimeAgo        = GetTimeAgo(m.SentAt),
                        IsRead         = false,
                        ConvoType      = "channel",
                        ConvoId        = ch.ChannelId.ToString()
                    });
                }
            }

            // Sort newest first, cap at 20
            notifItems = notifItems.OrderByDescending(x => x).Take(20).ToList();

            rptNotifs.DataSource = notifItems;
            rptNotifs.DataBind();

            bool hasUnread = notifItems.Count > 0;
            // Expose to markup via a hidden field so JS can show/hide the dot
            // (simpler than a Literal inside a non-UpdatePanel element)
            ClientScript.RegisterStartupScript(GetType(), "notifDot",
                $"document.getElementById('notifDot').style.display = '{(hasUnread ? "block" : "none")}';", true);
        }

        private static string GetTimeAgo(DateTime utc)
        {
            var diff = DateTime.UtcNow - utc;
            if (diff.TotalMinutes < 1)  return "just now";
            if (diff.TotalMinutes < 60) return $"{(int)diff.TotalMinutes}m ago";
            if (diff.TotalHours   < 24) return $"{(int)diff.TotalHours}h ago";
            return $"{(int)diff.TotalDays}d ago";
        }

        /* ── Load conversation (triggered by JS __doPostBack) ───────── */
        protected void btnLoadConvo_Click(object sender, EventArgs e)
        {
            string arg = Request.Form["__EVENTARGUMENT"] ?? "";
            ParseConvoArg(arg);
            MarkConversationRead();
            BindMessages();
            BindInfoPanel();
            UpdateConvoHeader();
            BindRail();
            BindNotifications();
            tmrRefresh.Enabled = true;
            upMessages.Update();
            upRail.Update();
            upInfoPanel.Update();
            upNotifs.Update();
        }

        private void ParseConvoArg(string arg)
        {
            var parts = arg.Split('_');
            if (parts.Length < 2) return;
            if (!int.TryParse(parts[1], out int id)) return;
            if (parts[0] == "dm")
            {
                SelectedConversationId = id;
                IsChannel = false;
                ViewState["SelectedConversationId"] = id;
                ViewState["IsChannel"] = false;
            }
            else
            {
                SelectedChannelId = id;
                IsChannel = true;
                ViewState["SelectedChannelId"] = id;
                ViewState["IsChannel"] = true;
            }
        }

        private void RestoreConvoState()
        {
            if (ViewState["IsChannel"] != null)
                IsChannel = (bool)ViewState["IsChannel"];
            if (ViewState["SelectedConversationId"] != null)
                SelectedConversationId = (int)ViewState["SelectedConversationId"];
            if (ViewState["SelectedChannelId"] != null)
                SelectedChannelId = (int)ViewState["SelectedChannelId"];
        }

        /// <summary>Mark all unread messages in the current conversation as read.</summary>
        private void MarkConversationRead()
        {
            List<Message> msgs;
            if (IsChannel)
                msgs = _messages.GetByChannel(SelectedChannelId);
            else
                msgs = _messages.GetByConversation(SelectedConversationId);

            foreach (var m in msgs.Where(m => m.SenderUserId != CurrentUser.UserId && !m.IsRead))
            {
                m.IsRead = true;
                _messages.Update(m);
            }
        }

        /* ── Message binding ────────────────────────────────────────── */
        private void BindMessages()
        {
            List<Message> messages;
            if (IsChannel)
                messages = _messages.GetByChannel(SelectedChannelId);
            else
                messages = _messages.GetByConversation(SelectedConversationId);

            var items = new List<object>();
            int? prevSender = null;
            foreach (var m in messages)
            {
                // "tight" = consecutive message from the same sender (avatar/sender hidden)
                bool tight = prevSender.HasValue && prevSender.Value == m.SenderUserId;
                int replyCount = _messages.GetReplies(m.MessageId).Count;

                items.Add(new
                {
                    MessageId      = m.MessageId,
                    IsOwn          = m.SenderUserId == CurrentUser.UserId,
                    SenderName     = m.Sender?.DisplayName ?? "Unknown",
                    SenderInitials = m.Sender?.GetInitials() ?? "?",
                    SenderColor    = m.Sender?.GetAvatarColor() ?? "#5B5FEF",
                    DisplayBody    = m.GetDisplayBody(),
                    FormattedTime  = m.GetFormattedTime(),
                    IsDeleted      = m.IsDeleted,
                    IsRead         = m.IsRead,
                    IsTight        = tight,
                    ReplyCount     = replyCount
                });
                prevSender = m.SenderUserId;
            }

            rptMessages.DataSource = items;
            rptMessages.DataBind();
        }

        /* ── Hover bar builder (called from markup) ─────────────────── */
        protected string BuildHoverBar(int messageId, bool isOwn)
        {
            return $@"
<div class=""msg-hover-bar"">
  <button type=""button"" class=""msg-hover-react"" data-msgid=""{messageId}"" title=""React"" aria-label=""Add reaction"">
    <svg width=""14"" height=""14"" viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" stroke-width=""2""><circle cx=""12"" cy=""12"" r=""10""/><path d=""M8 14s1.5 2 4 2 4-2 4-2""/><line x1=""9"" y1=""9"" x2=""9.01"" y2=""9""/><line x1=""15"" y1=""9"" x2=""15.01"" y2=""9""/></svg>
  </button>
  <button type=""button"" class=""msg-hover-reply"" data-msgid=""{messageId}"" title=""Reply in thread"" aria-label=""Reply in thread"">
    <svg width=""14"" height=""14"" viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" stroke-width=""2.2""><polyline points=""9 14 4 9 9 4""/><path d=""M20 20v-7a4 4 0 0 0-4-4H4""/></svg>
  </button>
  <button type=""button"" class=""msg-hover-more"" data-msgid=""{messageId}"" data-own=""{(isOwn ? "true" : "false")}"" title=""More"" aria-label=""More message options"">
    <svg width=""14"" height=""14"" viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" stroke-width=""2""><circle cx=""12"" cy=""12"" r=""1""/><circle cx=""19"" cy=""12"" r=""1""/><circle cx=""5"" cy=""12"" r=""1""/></svg>
  </button>
</div>";
        }

        /* ── Thread link builder (called from markup) ───────────────── */
        protected string BuildThreadLink(int messageId, int replyCount)
        {
            string label = replyCount + (replyCount == 1 ? " reply" : " replies") + " in thread";
            return $@"<button type=""button"" class=""thread-link"" onclick=""openThread({messageId})"">
  <svg width=""12"" height=""12"" viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" stroke-width=""2.4""><polyline points=""9 14 4 9 9 4""/><path d=""M20 20v-7a4 4 0 0 0-4-4H4""/></svg>
  {System.Web.HttpUtility.HtmlEncode(label)}</button>";
        }

        /* ── Read-tick builder (called from markup) ─────────────────── */
        protected string BuildReadTick(bool isRead)
        {
            string color = isRead ? "var(--signal-500)" : "var(--ash-300)";
            return $@"<svg width=""13"" height=""13"" viewBox=""0 0 24 24"" fill=""none"" stroke=""{color}"" stroke-width=""2.5"" title=""{(isRead ? "Read" : "Delivered")}"">
  <path d=""m3 12 5 5L21 4""/><path d=""m3 17 5 5""/>
</svg>";
        }

        /* ── Reactions builder (called from markup) ─────────────────── */
        protected string BuildReactionsHtml(int messageId)
        {
            var reactions = _reactions.GetByMessage(messageId);
            if (reactions == null || !reactions.Any()) return "";

            var grouped = reactions
                .GroupBy(r => r.Emoji)
                .Select(g => new { Emoji = g.Key, Count = g.Count(), Mine = g.Any(r => r.UserId == CurrentUser.UserId) });

            var pills = string.Join("", grouped.Select(g =>
                $@"<button type=""button"" class=""reaction-pill {(g.Mine ? "mine" : "")}"" onclick=""postReaction({messageId}, '{System.Web.HttpUtility.JavaScriptStringEncode(g.Emoji)}')"" title=""{g.Count} {(g.Count == 1 ? "reaction" : "reactions")}"">
  {g.Emoji} <span>{g.Count}</span>
</button>"));

            return $@"<div class=""reactions"">
{pills}
<button type=""button"" class=""reaction-add-btn msg-hover-react"" data-msgid=""{messageId}"" title=""Add reaction"">+</button>
</div>";
        }

        /* ── React button postback ───────────────────────────────────── */
        protected void btnReact_Click(object sender, EventArgs e)
        {
            RestoreConvoState();
            string arg = Request.Form["__EVENTARGUMENT"] ?? "";
            // arg format: "msgId_emoji" but emoji may contain underscores — split on first _ only
            int sep = arg.IndexOf('_');
            if (sep < 0) return;
            if (!int.TryParse(arg.Substring(0, sep), out int msgId)) return;
            string emoji = arg.Substring(sep + 1);

            // We also accept the hidden fields approach for reliability
            string hdnMsgId  = Request.Form["hdnReactMsgId"]  ?? msgId.ToString();
            string hdnEmoji  = Request.Form["hdnReactEmoji"]  ?? emoji;
            if (int.TryParse(hdnMsgId, out int realMsgId) && !string.IsNullOrEmpty(hdnEmoji))
            {
                msgId = realMsgId;
                emoji = hdnEmoji;
            }

            _reactions.Toggle(msgId, CurrentUser.UserId, emoji);
            BindMessages();
            upMessages.Update();
        }

        /* ── Delete (soft) message postback ─────────────────────────── */
        protected void btnDeleteMsg_Click(object sender, EventArgs e)
        {
            RestoreConvoState();
            int msgId;
            if (!int.TryParse(Request.Form["hdnDeleteMsgId"] ?? "", out msgId) || msgId <= 0) return;

            var msg = _messages.GetById(msgId);
            if (msg == null || msg.SenderUserId != CurrentUser.UserId) return; // only own messages

            _messages.MarkDeleted(msgId);
            BindMessages();
            BindRail();
            BindNotifications();
            upMessages.Update();
            upRail.Update();
            upNotifs.Update();
        }

        /* ── Conversation header (title/subtitle/avatar) ────────────── */
        /// <summary>
        /// The convo header lives outside the UpdatePanels, so it is updated
        /// client-side with a registered startup script rather than re-rendered.
        /// </summary>
        private void UpdateConvoHeader()
        {
            string title, subtitle, avatar;

            if (IsChannel)
            {
                var ch = _channels.GetById(SelectedChannelId);
                if (ch == null) return;
                title    = "#" + ch.Name;
                subtitle = ch.Members.Count + (ch.Members.Count == 1 ? " member" : " members");
                avatar   = "<div class=\"channel-icon\" style=\"width:38px;height:38px;\">" + System.Web.HttpUtility.HtmlEncode(ch.Icon ?? "💬") + "</div>";
            }
            else
            {
                var convo = _convos.GetById(SelectedConversationId);
                if (convo == null) return;
                var other = convo.UserAId == CurrentUser.UserId ? convo.UserB : convo.UserA;
                if (other == null) return;
                title    = other.DisplayName;
                subtitle = other.IsOnline ? "Active now" : "Offline";
                avatar   = "<div class=\"avatar\" style=\"width:38px;height:38px;background:" + other.GetAvatarColor() +
                           ";font-size:.9rem;\">" + other.GetInitials() + "</div><span class=\"presence " +
                           (other.IsOnline ? "online" : "offline") + "\"></span>";
            }

            string js =
                "document.getElementById('convoTitle').innerHTML=" + JsStr(title) + ";" +
                "document.getElementById('convoSubtitle').textContent=" + JsStr(subtitle) + ";" +
                "document.getElementById('convoAvatarWrap').innerHTML=" + JsStr(avatar) + ";";
            ClientScript.RegisterStartupScript(GetType(), "convoHeader", js, true);
        }

        private static string JsStr(string s) =>
            "\"" + System.Web.HttpUtility.JavaScriptStringEncode(s) + "\"";

        /* ── Info panel ─────────────────────────────────────────────── */
        private void BindInfoPanel()
        {
            if (IsChannel)
            {
                var ch = _channels.GetById(SelectedChannelId);
                if (ch == null) return;
                litInfoPanel.Text = BuildChannelInfoPanel(ch);
            }
            else
            {
                var convo = _convos.GetById(SelectedConversationId);
                if (convo == null) return;
                var other = convo.UserAId == CurrentUser.UserId ? convo.UserB : convo.UserA;
                litInfoPanel.Text = BuildUserInfoPanel(other);
            }
        }

        private string BuildUserInfoPanel(User u)
        {
            string sharedFiles = BuildSharedFilesSection();
            return $@"
<div class=""info-panel-head"">
  <strong class=""font-display"" style=""font-size:.9rem;"">Profile</strong>
  <button class=""icon-btn"" onclick=""toggleInfoPanel()"" aria-label=""Close"">
    <svg width=""16"" height=""16"" viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" stroke-width=""2.2""><path d=""M18 6 6 18M6 6l12 12""/></svg>
  </button>
</div>
<div class=""info-hero"">
  <div class=""avatar mx-auto mb-2"" style=""width:64px;height:64px;background:{u.GetAvatarColor()};font-size:1.4rem;"">{u.GetInitials()}</div>
  <h6 class=""font-display fw-bold mb-0"">{System.Web.HttpUtility.HtmlEncode(u.DisplayName)}</h6>
  <p style=""font-size:.82rem;color:var(--ash-500);margin:.15rem 0 .5rem;"">{System.Web.HttpUtility.HtmlEncode(u.StatusMessage ?? "")}</p>
  <span class=""badge-soft""><span style=""display:inline-block;width:6px;height:6px;border-radius:50%;background:{(u.IsOnline ? "var(--pulse-400)" : "var(--ash-300)")};margin-right:4px;""></span>{(u.IsOnline ? "Active now" : "Offline")}</span>
  <div class=""d-flex gap-2 justify-content-center mt-3"">
    <button class=""quick-action"" onclick=""showToast('Voice call','Calling requires a future SignalR/WebRTC enhancement (SRS §FR-CALL).')"">
      <svg width=""15"" height=""15"" viewBox=""0 0 24 24"" fill=""none"" stroke=""var(--signal-500)"" stroke-width=""2""><path d=""M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.13 11.9a19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 3.08 1h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L8.09 8.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92Z""/></svg>
      <span>Call</span>
    </button>
    <button class=""quick-action"" onclick=""showToast('Video call','Video calling is a planned enhancement (SRS §FR-CALL).')"">
      <svg width=""15"" height=""15"" viewBox=""0 0 24 24"" fill=""none"" stroke=""var(--signal-500)"" stroke-width=""2""><path d=""m23 7-7 5 7 5V7Z""/><rect x=""1"" y=""5"" width=""15"" height=""14"" rx=""2""/></svg>
      <span>Video</span>
    </button>
  </div>
</div>
{sharedFiles}";
        }

        private string BuildChannelInfoPanel(Channel ch)
        {
            bool isOwner = ch.OwnerUserId == CurrentUser.UserId;
            var memberRows = string.Join("", ch.Members.Select(m => $@"
<div class=""member-row"">
  <div class=""avatar-wrap on-paper"">
    <div class=""avatar"" style=""width:32px;height:32px;background:{m.User?.GetAvatarColor()};font-size:.75rem;"">{m.User?.GetInitials()}</div>
    <span class=""presence {(m.User?.IsOnline == true ? "online" : "offline")}""></span>
  </div>
  <div class=""flex-grow-1"" style=""min-width:0;"">
    <div style=""font-size:.83rem;font-weight:600;"">{System.Web.HttpUtility.HtmlEncode(m.User?.DisplayName ?? "")}{(m.UserId == CurrentUser.UserId ? " <span style='color:var(--ash-400);font-size:.72rem;'>(You)</span>" : "")}</div>
    <div style=""font-size:.65rem;color:var(--ash-400);"">{(ch.OwnerUserId == m.UserId ? "Owner" : "Member")}</div>
  </div>
</div>"));

            string sharedFiles = BuildSharedFilesSection();

            return $@"
<div class=""info-panel-head"">
  <strong class=""font-display"" style=""font-size:.9rem;"">Channel Info</strong>
  <button class=""icon-btn"" onclick=""toggleInfoPanel()"" aria-label=""Close"">
    <svg width=""16"" height=""16"" viewBox=""0 0 24 24"" fill=""none"" stroke=""currentColor"" stroke-width=""2.2""><path d=""M18 6 6 18M6 6l12 12""/></svg>
  </button>
</div>
<div class=""info-hero"">
  <div style=""font-size:2.5rem;margin-bottom:.5rem;"">{ch.Icon}</div>
  <h6 class=""font-display fw-bold mb-0"">#{System.Web.HttpUtility.HtmlEncode(ch.Name)}</h6>
  <p style=""font-size:.82rem;color:var(--ash-500);margin:.15rem 0 .5rem;"">{System.Web.HttpUtility.HtmlEncode(ch.Topic ?? "")}</p>
  <span class=""badge-soft"">{ch.Members.Count} members</span>
</div>
<div class=""info-section"">
  <div class=""d-flex justify-content-between align-items-center mb-2"">
    <span class=""info-section-title"">Members — {ch.Members.Count}</span>
  </div>
  {memberRows}
</div>
{sharedFiles}";
        }

        private string BuildSharedFilesSection()
        {
            // Placeholder — a real implementation would query AttachmentRepository
            return @"
<div class=""info-section"">
  <div class=""d-flex justify-content-between align-items-center mb-2"">
    <span class=""info-section-title"">Shared files</span>
  </div>
  <p style=""font-size:.8rem;color:var(--ash-400);text-align:center;padding:.5rem 0;"">No files shared yet.</p>
</div>";
        }

        /* ── Thread panel ────────────────────────────────────────────── */
        protected void btnLoadThread_Click(object sender, EventArgs e)
        {
            RestoreConvoState();
            string arg = Request.Form["__EVENTARGUMENT"] ?? "";
            if (!int.TryParse(arg, out int msgId))
            {
                string hdnMsgId = Request.Form["hdnThreadMsgId"] ?? "";
                int.TryParse(hdnMsgId, out msgId);
            }
            if (msgId <= 0) return;

            ThreadParentMessageId = msgId;
            var parent = _messages.GetById(msgId);
            if (parent == null) return;

            // Build parent bubble HTML
            string parentHtml = $@"
<div class=""d-flex gap-2"">
  <div class=""avatar"" style=""width:28px;height:28px;background:{parent.Sender?.GetAvatarColor()};font-size:.62rem;flex-shrink:0;"">{parent.Sender?.GetInitials()}</div>
  <div style=""min-width:0;"">
    <div style=""font-size:.78rem;font-weight:700;"">{System.Web.HttpUtility.HtmlEncode(parent.Sender?.DisplayName ?? "")}
      <span class=""font-mono"" style=""font-weight:400;color:var(--ash-400);font-size:.68rem;"">{parent.GetFormattedTime()}</span>
    </div>
    <div style=""font-size:.82rem;margin-top:.15rem;"">{System.Web.HttpUtility.HtmlEncode(parent.GetDisplayBody())}</div>
  </div>
</div>";

            // Replies: messages that share the same parent (stored via ParentMessageId if the schema supports it)
            // Fall back to showing only the parent for now if no reply FK exists yet
            var replies = _messages.GetReplies(msgId);
            string repliesHtml = string.Join("", replies.Select(r =>
            {
                bool own = r.SenderUserId == CurrentUser.UserId;
                return $@"
<div class=""msg-row {(own ? "own" : "")}"">
  {(own ? "" : $"<div class=\"avatar\" style=\"width:28px;height:28px;background:{r.Sender?.GetAvatarColor()};font-size:.62rem;flex-shrink:0;\">{r.Sender?.GetInitials()}</div>")}
  <div class=""msg-col"">
    {(own ? "" : $"<div class=\"msg-sender\">{System.Web.HttpUtility.HtmlEncode(r.Sender?.DisplayName ?? "")}</div>")}
    <div class=""bubble"">{System.Web.HttpUtility.HtmlEncode(r.GetDisplayBody())}</div>
    <div class=""msg-foot""><span class=""t"">{r.GetFormattedTime()}</span></div>
  </div>
</div>";
            }));

            // Inject via startup script (the offcanvas body is outside UpdatePanels)
            string parentJs  = System.Web.HttpUtility.JavaScriptStringEncode(parentHtml);
            string repliesJs = System.Web.HttpUtility.JavaScriptStringEncode(repliesHtml);
            string countJs   = replies.Count + " " + (replies.Count == 1 ? "reply" : "replies");

            ClientScript.RegisterStartupScript(GetType(), "openThread", $@"
(function() {{
  document.getElementById('threadParent').innerHTML   = '{parentJs}';
  document.getElementById('threadReplies').innerHTML  = '{repliesJs}';
  document.getElementById('threadReplyCount').textContent = '{countJs}';
  var oc = new bootstrap.Offcanvas(document.getElementById('threadOffcanvas'));
  oc.show();
}})();", true);
        }

        protected void btnThreadSend_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            RestoreConvoState();
            string body = txtThreadReply.Text.Trim();
            if (string.IsNullOrEmpty(body) || ThreadParentMessageId <= 0) return;

            // Send as a reply to the parent message
            int? convoId    = IsChannel ? (int?)null : SelectedConversationId;
            int? channelId  = IsChannel ? (int?)SelectedChannelId : (int?)null;

            _messages.Add(new Message
            {
                ConversationId    = convoId > 0 ? convoId : null,
                ChannelId         = channelId > 0 ? channelId : null,
                SenderUserId      = CurrentUser.UserId,
                Body              = body,
                SentAt            = DateTime.UtcNow,
                ParentMessageId   = ThreadParentMessageId
            });

            txtThreadReply.Text = "";
            // Reload thread view via another btnLoadThread postback simulation
            btnLoadThread_Click(sender, e);
        }

        /* ── Timer tick (auto-refresh messages) ─────────────────────── */
        protected void tmrRefresh_Tick(object sender, EventArgs e)
        {
            RestoreConvoState();
            if (SelectedConversationId > 0 || SelectedChannelId > 0)
            {
                BindMessages();
                BindRail();
                BindNotifications();
                upMessages.Update();
                upRail.Update();
                upNotifs.Update();
            }
        }

        /* ── Send message ────────────────────────────────────────────── */
        protected void btnSend_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            RestoreConvoState();

            string body = txtMessage.Text.Trim();
            if (string.IsNullOrEmpty(body)) return;

            if (IsChannel && SelectedChannelId > 0)
            {
                _messages.Add(new Message
                {
                    ChannelId    = SelectedChannelId,
                    SenderUserId = CurrentUser.UserId,
                    Body         = body,
                    SentAt       = DateTime.UtcNow
                });
            }
            else if (!IsChannel && SelectedConversationId > 0)
            {
                _messages.Add(new Message
                {
                    ConversationId = SelectedConversationId,
                    SenderUserId   = CurrentUser.UserId,
                    Body           = body,
                    SentAt         = DateTime.UtcNow
                });
            }

            txtMessage.Text = "";
            BindMessages();
            BindRail();
            upMessages.Update();
            upRail.Update();
        }

        /* ── Rail repeater item commands ─────────────────────────────── */
        protected void rptDMs_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e) { }
        protected void rptChannels_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e) { }

        /* ── User search (new DM modal) ──────────────────────────────── */
        protected void txtUserSearch_TextChanged(object sender, EventArgs e)
        {
            string q = txtUserSearch.Text.Trim();
            var results = _users.Search(q)
                .Where(u => u.UserId != CurrentUser.UserId)
                .ToList();
            rptUserSearch.DataSource = results;
            rptUserSearch.DataBind();
            upUserSearch.Update();
        }

        protected void rptUserSearch_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "StartDM") return;
            int otherId = int.Parse(e.CommandArgument.ToString());
            var convo   = _convos.GetOrCreate(CurrentUser.UserId, otherId);
            SelectedConversationId = convo.ConversationId;
            IsChannel = false;
            ViewState["SelectedConversationId"] = convo.ConversationId;
            ViewState["IsChannel"] = false;
            BindMessages();
            BindRail();
            BindInfoPanel();
            UpdateConvoHeader();
            tmrRefresh.Enabled = true;
            upMessages.Update();
            upRail.Update();
            upInfoPanel.Update();
        }

        protected string BuildUserSearchItem(string displayName, string username, string initials, string color, bool isOnline)
        {
            return $@"<div class=""d-flex align-items-center gap-2 w-100"">
  <div class=""avatar"" style=""width:34px;height:34px;background:{color};font-size:.78rem;flex-shrink:0;"">{System.Web.HttpUtility.HtmlEncode(initials)}</div>
  <div style=""text-align:left;min-width:0;"">
    <div style=""font-size:.85rem;font-weight:600;color:var(--ash-800);"">{System.Web.HttpUtility.HtmlEncode(displayName)}</div>
    <div style=""font-size:.75rem;color:var(--ash-500);"">@{System.Web.HttpUtility.HtmlEncode(username)} · {(isOnline ? "Online" : "Offline")}</div>
  </div>
</div>";
        }

        /* ── Create channel ──────────────────────────────────────────── */
        protected void btnCreateChannel_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string name  = txtNewChannelName.Text.Trim().ToLower().Replace(" ", "-");
            string topic = txtNewChannelTopic.Text.Trim();

            var ch = new Channel
            {
                Name        = name,
                Topic       = topic,
                Icon        = "💬",
                OwnerUserId = CurrentUser.UserId,
                CreatedAt   = DateTime.UtcNow
            };
            _channels.Add(ch);
            _channels.AddMember(ch.ChannelId, CurrentUser.UserId);
            SelectedChannelId = ch.ChannelId;
            IsChannel = true;
            ViewState["SelectedChannelId"] = ch.ChannelId;
            ViewState["IsChannel"] = true;

            txtNewChannelName.Text  = "";
            txtNewChannelTopic.Text = "";

            BindMessages();
            BindRail();
            BindInfoPanel();
            UpdateConvoHeader();
            tmrRefresh.Enabled = true;
            upMessages.Update();
            upRail.Update();
            upInfoPanel.Update();
        }

        /* ── Save profile settings ───────────────────────────────────── */
        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            CurrentUser.DisplayName   = txtSetDisplayName.Text.Trim();
            CurrentUser.StatusMessage = txtSetStatus.Text.Trim();
            _users.Update(CurrentUser);

            litFooterName.Text = System.Web.HttpUtility.HtmlEncode(CurrentUser.DisplayName);
            pnlSettingsSaved.Visible = true;
            upSettings.Update();
        }

        /* ── Logout ──────────────────────────────────────────────────── */
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            CurrentUser.IsOnline   = false;
            CurrentUser.LastSeenAt = DateTime.UtcNow;
            _users.Update(CurrentUser);
            FormsAuthentication.SignOut();
            Response.Redirect("~/Login.aspx", true);
        }
    }
}
