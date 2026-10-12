using System;
using System.Linq;
using RelayChat.Web.Common;
using RelayChat.Web.Data.Repositories;
using RelayChat.Web.Models;
using RelayChat.Web.Services;

namespace RelayChat.Web.Admin
{
    /// <summary>
    /// Admin console. Inherits AdminPage which enforces authentication
    /// AND the Administrator role (two-level inheritance guard).
    /// </summary>
    public partial class AdminDashboard : AdminPage
    {
        private readonly IUserRepository     _users    = new UserRepository();
        private readonly IChannelRepository  _channels = new ChannelRepository();
        private readonly IMessageRepository  _messages = new MessageRepository();
        private readonly IAuditLogRepository _logs     = new AuditLogRepository();
        private AdminService _adminService;

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            _adminService = new AdminService(_users, _channels);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                BindAll();
        }

        private void BindAll()
        {
            BindStats();
            BindRecentActivity();
            BindDashUsers();
            BindUsers(null);
            BindChannels();
            BindFlagged();
            BindLogs();
        }

        /* ── Stats ───────────────────────────────────────────────── */
        private void BindStats()
        {
            litStatUsers.Text     = _adminService.GetAllUsers().Count.ToString();
            litStatChannels.Text  = _adminService.GetAllChannels().Count.ToString();
            litStatOnline.Text    = _adminService.GetOnlineCount().ToString();
            litStatSuspended.Text = _adminService.GetSuspendedCount().ToString();
        }

        /* ── Recent activity widget (dashboard) ─────────────────── */
        private void BindRecentActivity()
        {
            var items = _logs.GetAll()
                .Take(6)                             // already ordered DESC by GetAll()
                .Select(l => new
                {
                    ActorName     = l.Actor?.DisplayName ?? ("User #" + l.ActorUserId),
                    Action        = l.Action,
                    Target        = l.EntityType + (l.EntityId.HasValue ? " #" + l.EntityId : ""),
                    FormattedTime = TimeAgo(l.CreatedAt)
                }).ToList();

            rptRecentActivity.DataSource = items;
            rptRecentActivity.DataBind();
        }

        /* ── Dashboard users at-a-glance ────────────────────────── */
        private void BindDashUsers()
        {
            rptDashUsers.DataSource = _adminService.GetAllUsers();
            rptDashUsers.DataBind();
        }

        /* ── Users panel ─────────────────────────────────────────── */
        private void BindUsers(string query)
        {
            var users = string.IsNullOrWhiteSpace(query)
                ? _adminService.GetAllUsers()
                : _adminService.SearchUsers(query);
            rptUsers.DataSource = users;
            rptUsers.DataBind();
        }

        /* ── Channels panel ──────────────────────────────────────── */
        private void BindChannels()
        {
            rptAdminChannels.DataSource = _adminService.GetAllChannels();
            rptAdminChannels.DataBind();
        }

        /* ── Moderation panel ────────────────────────────────────── */
        private void BindFlagged()
        {
            var flagged = _messages.GetFlagged()
                .Select(m => new
                {
                    MessageId      = m.MessageId,
                    SenderName     = m.Sender?.DisplayName ?? "Unknown",
                    SenderInitials = m.Sender?.GetInitials() ?? "?",
                    SenderColor    = m.Sender?.GetAvatarColor() ?? "#5B5FEF",
                    Body           = m.Body.Length > 120 ? m.Body.Substring(0, 117) + "…" : m.Body,
                    ContextLabel   = m.ChannelId.HasValue ? "#channel" : "DM",
                    ReportedAt     = TimeAgo(m.FlaggedAt ?? m.SentAt)
                }).ToList();

            rptFlagged.DataSource = flagged;
            rptFlagged.DataBind();
            lblNoFlagged.Visible = flagged.Count == 0;
        }

        /* ── Activity Log panel ──────────────────────────────────── */
        private void BindLogs()
        {
            var logs = _logs.GetAll()
                .Select(l => new
                {
                    ActorName     = l.Actor?.DisplayName ?? ("User #" + l.ActorUserId),
                    Action        = l.Action,
                    Target        = l.EntityType + (l.EntityId.HasValue ? " #" + l.EntityId : ""),
                    IpAddress     = l.IpAddress,
                    FormattedTime = l.CreatedAt.ToLocalTime().ToString("MMM d, yyyy · h:mm tt")
                }).ToList();

            rptLogs.DataSource = logs;
            rptLogs.DataBind();
            lblNoLogs.Visible = logs.Count == 0;
        }

        /* ── User search ─────────────────────────────────────────── */
        protected void txtUserSearch_TextChanged(object sender, EventArgs e)
        {
            BindUsers(txtUserSearch.Text.Trim());
            upUsers.Update();
        }

        /* ── Suspend / Reactivate ────────────────────────────────── */
        protected void rptUsers_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ToggleSuspend") return;

            int userId = int.Parse(e.CommandArgument.ToString());
            var user   = _users.GetById(userId);
            if (user == null || user.UserId == CurrentUser.UserId) return;

            bool wasSuspended = user.IsSuspended;
            if (wasSuspended)
                _adminService.ReactivateUser(userId);
            else
                _adminService.SuspendUser(userId);

            _logs.Add(new AuditLog
            {
                ActorUserId = CurrentUser.UserId,
                Action      = wasSuspended ? "Reactivated" : "Suspended",
                EntityType  = "User",
                EntityId    = userId,
                Details     = $"@{user.Username}",
                IpAddress   = Request.UserHostAddress,
                CreatedAt   = DateTime.UtcNow
            });

            BindStats();
            BindUsers(txtUserSearch.Text.Trim());
            BindDashUsers();
            BindRecentActivity();
            upUsers.Update();
        }

        /* ── Moderation actions ──────────────────────────────────── */
        protected void rptFlagged_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument.ToString(), out int msgId)) return;

            if (e.CommandName == "Remove")
            {
                _messages.MarkDeleted(msgId);
                _logs.Add(new AuditLog
                {
                    ActorUserId = CurrentUser.UserId,
                    Action      = "Removed",
                    EntityType  = "Message",
                    EntityId    = msgId,
                    Details     = "Removed flagged message",
                    IpAddress   = Request.UserHostAddress,
                    CreatedAt   = DateTime.UtcNow
                });
            }
            else if (e.CommandName == "Dismiss")
            {
                _messages.ClearFlag(msgId);
                _logs.Add(new AuditLog
                {
                    ActorUserId = CurrentUser.UserId,
                    Action      = "DismissedFlag",
                    EntityType  = "Message",
                    EntityId    = msgId,
                    Details     = "Dismissed moderation flag",
                    IpAddress   = Request.UserHostAddress,
                    CreatedAt   = DateTime.UtcNow
                });
            }

            BindFlagged();
            BindLogs();
            upModeration.Update();
        }

        /* ── Helper ──────────────────────────────────────────────── */
        private static string TimeAgo(DateTime utc)
        {
            var d = DateTime.UtcNow - utc;
            if (d.TotalMinutes < 1)  return "just now";
            if (d.TotalMinutes < 60) return $"{(int)d.TotalMinutes}m ago";
            if (d.TotalHours   < 24) return $"{(int)d.TotalHours}h ago";
            if (d.TotalDays    < 7)  return $"{(int)d.TotalDays}d ago";
            return utc.ToLocalTime().ToString("MMM d");
        }
    }
}
