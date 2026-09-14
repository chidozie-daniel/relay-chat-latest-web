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

        /* ── Repositories (composed per-request) ────────────────────── */
        private readonly IConversationRepository _convos   = new ConversationRepository();
        private readonly IChannelRepository      _channels = new ChannelRepository();
        private readonly IMessageRepository      _messages = new MessageRepository();
        private readonly IUserRepository         _users    = new UserRepository();

        /* ── Page lifecycle ─────────────────────────────────────────── */
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindCurrentUser();
                BindRail();
                // Start polling timer only once a conversation is selected
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
                var lastMsg = _messages.GetByConversation(c.ConversationId).LastOrDefault();
                return new
                {
                    ConversationId   = c.ConversationId,
                    OtherUser        = other,
                    LastMessageTime    = lastMsg != null ? lastMsg.GetFormattedTime() : "",
                    LastMessagePreview = lastMsg != null ? TruncatePreview(lastMsg.GetDisplayBody()) : "No messages yet"
                };
            }).ToList();
            rptDMs.DataSource = dmItems;
            rptDMs.DataBind();

            // Channels
            var channels = _channels.GetByMember(CurrentUser.UserId);
            var chItems = channels.Select(ch =>
            {
                var lastMsg = _messages.GetByChannel(ch.ChannelId).LastOrDefault();
                return new
                {
                    ChannelId          = ch.ChannelId,
                    Name               = ch.Name,
                    Icon               = ch.Icon ?? "💬",
                    LastMessageTime    = lastMsg != null ? lastMsg.GetFormattedTime() : "",
                    LastMessagePreview = lastMsg != null ? TruncatePreview(lastMsg.GetDisplayBody()) : "No messages yet"
                };
            }).ToList();
            rptChannels.DataSource = chItems;
            rptChannels.DataBind();
        }

        private static string TruncatePreview(string s) =>
            s.Length > 60 ? s.Substring(0, 57) + "…" : s;

        /* ── Load conversation (triggered by JS __doPostBack) ───────── */
        protected void btnLoadConvo_Click(object sender, EventArgs e)
        {
            // EventArgument format: "dm_5" or "channel_3"
            string arg = Request.Form["__EVENTARGUMENT"] ?? "";
            ParseConvoArg(arg);
            BindMessages();
            BindInfoPanel();
            BindRail();
            tmrRefresh.Enabled = true;
            upMessages.Update();
            upRail.Update();
            upInfoPanel.Update();
        }

        private void ParseConvoArg(string arg)
        {
            var parts = arg.Split('_');
            if (parts.Length < 2) return;
            bool ok = int.TryParse(parts[1], out int id);
            if (!ok) return;
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

        /* ── Message binding ────────────────────────────────────────── */
        private void BindMessages()
        {
            List<Message> messages;
            if (IsChannel)
                messages = _messages.GetByChannel(SelectedChannelId);
            else
                messages = _messages.GetByConversation(SelectedConversationId);

            var items = messages.Select(m => new
            {
                IsOwn          = m.SenderUserId == CurrentUser.UserId,
                SenderName     = m.Sender?.DisplayName ?? "Unknown",
                SenderInitials = m.Sender?.GetInitials() ?? "?",
                SenderColor    = m.Sender?.GetAvatarColor() ?? "#5B5FEF",
                DisplayBody    = m.GetDisplayBody(),
                FormattedTime  = m.GetFormattedTime(),
                IsDeleted      = m.IsDeleted
            }).ToList();

            rptMessages.DataSource = items;
            rptMessages.DataBind();
        }

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
</div>";
        }

        private string BuildChannelInfoPanel(Channel ch)
        {
            var memberRows = string.Join("", ch.Members.Select(m => $@"
<div class=""member-row"">
  <div class=""avatar"" style=""width:32px;height:32px;background:{m.User?.GetAvatarColor()};font-size:.75rem;"">{m.User?.GetInitials()}</div>
  <div class=""flex-grow-1"" style=""min-width:0;"">
    <div style=""font-size:.83rem;font-weight:600;"">{System.Web.HttpUtility.HtmlEncode(m.User?.DisplayName ?? "")}</div>
    <div style=""font-size:.65rem;color:var(--ash-400);"">{(ch.OwnerUserId == m.UserId ? "Owner" : "Member")}</div>
  </div>
</div>"));

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
  <div class=""info-section-title mb-2"">Members</div>
  {memberRows}
</div>";
        }

        /* ── Timer tick (auto-refresh messages) ─────────────────────── */
        protected void tmrRefresh_Tick(object sender, EventArgs e)
        {
            RestoreConvoState();
            if (SelectedConversationId > 0 || SelectedChannelId > 0)
            {
                BindMessages();
                upMessages.Update();
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
                ChatService.SendChannelMessage(SelectedChannelId, CurrentUser.UserId, body);
            else if (!IsChannel && SelectedConversationId > 0)
                ChatService.SendDirectMessage(SelectedConversationId, CurrentUser.UserId, body);

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
            tmrRefresh.Enabled = true;
            upMessages.Update();
            upRail.Update();
            upInfoPanel.Update();
        }

        /// <summary>Renders a user search result as an HTML snippet for the button label.</summary>
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

            var ch = ChatService.CreateChannel(name, topic, "💬", CurrentUser.UserId);
            SelectedChannelId = ch.ChannelId;
            IsChannel = true;
            ViewState["SelectedChannelId"] = ch.ChannelId;
            ViewState["IsChannel"] = true;

            txtNewChannelName.Text  = "";
            txtNewChannelTopic.Text = "";

            BindMessages();
            BindRail();
            BindInfoPanel();
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
