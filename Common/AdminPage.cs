namespace RelayChat.Web.Common
{
    /// <summary>
    /// Base class for Admin pages. Inherits SecurePage (which already
    /// enforces authentication) and additionally enforces the Administrator
    /// role. Admin\AdminDashboard.aspx inherits this.
    /// </summary>
    public class AdminPage : SecurePage
    {
        protected override void OnInit(System.EventArgs e)
        {
            base.OnInit(e);  // runs auth check from SecurePage first

            if (CurrentUser != null && CurrentUser.Role != "Administrator")
            {
                // Not an admin — send back to chat
                Response.Redirect("~/Chat.aspx", true);
            }
        }
    }
}
