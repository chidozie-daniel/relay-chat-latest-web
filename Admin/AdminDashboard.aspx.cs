using System;
using System.Web.UI;
using RelayChat.Web.Common;
using RelayChat.Web.Data.Repositories;
using RelayChat.Web.Services;

namespace RelayChat.Web.Admin
{
    /// <summary>
    /// Admin console. Inherits AdminPage which enforces authentication
    /// AND the Administrator role (two-level inheritance guard).
    /// </summary>
    public partial class AdminDashboard : AdminPage
    {
        private readonly IUserRepository    _users    = new UserRepository();
        private readonly IChannelRepository _channels = new ChannelRepository();
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
            BindDashUsers();
            BindUsers(null);
            BindChannels();
        }

        private void BindStats()
        {
            var allUsers = _adminService.GetAllUsers();
            litStatUsers.Text     = allUsers.Count.ToString();
            litStatChannels.Text  = _adminService.GetAllChannels().Count.ToString();
            litStatOnline.Text    = _adminService.GetOnlineCount().ToString();
            litStatSuspended.Text = _adminService.GetSuspendedCount().ToString();
        }

        private void BindDashUsers()
        {
            rptDashUsers.DataSource = _adminService.GetAllUsers();
            rptDashUsers.DataBind();
        }

        private void BindUsers(string query)
        {
            var users = string.IsNullOrWhiteSpace(query)
                ? _adminService.GetAllUsers()
                : _adminService.SearchUsers(query);
            rptUsers.DataSource = users;
            rptUsers.DataBind();
        }

        private void BindChannels()
        {
            rptAdminChannels.DataSource = _adminService.GetAllChannels();
            rptAdminChannels.DataBind();
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
            if (user == null) return;

            // Don't let an admin suspend themselves
            if (user.UserId == CurrentUser.UserId) return;

            if (user.IsSuspended)
                _adminService.ReactivateUser(userId);
            else
                _adminService.SuspendUser(userId);

            BindStats();
            BindUsers(txtUserSearch.Text.Trim());
            BindDashUsers();
            upUsers.Update();
        }
    }
}
