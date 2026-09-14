using System.Web.Security;
using RelayChat.Web.Data.Repositories;
using RelayChat.Web.Models;

namespace RelayChat.Web.Common
{
    /// <summary>
    /// Base class for pages that require an authenticated user.
    /// Inherits BasePage and adds an auth guard on every load.
    /// Chat.aspx inherits this.
    /// </summary>
    public class SecurePage : BasePage
    {
        /// <summary>The currently signed-in user — loaded once per request.</summary>
        protected User CurrentUser { get; private set; }

        protected override void OnInit(System.EventArgs e)
        {
            base.OnInit(e);

            if (!User.Identity.IsAuthenticated)
            {
                FormsAuthentication.RedirectToLoginPage();
                return;
            }

            // Load from DB each request — keeps data fresh
            string username = User.Identity.Name;
            CurrentUser = new UserRepository().GetByUsernameOrEmail(username);

            if (CurrentUser == null || CurrentUser.IsSuspended)
            {
                FormsAuthentication.SignOut();
                FormsAuthentication.RedirectToLoginPage();
            }
        }
    }
}
