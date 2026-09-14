using System;
using System.Web.Security;
using System.Web.UI;
using RelayChat.Web.Common;

namespace RelayChat.Web
{
    /// <summary>
    /// Login page. Inherits BasePage for AuthService composition.
    /// All field-level validation is handled by ASP.NET validator controls
    /// in the markup; this code-behind only handles the business logic.
    /// </summary>
    public partial class Login : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (User.Identity.IsAuthenticated)
                Response.Redirect("~/Chat.aspx", true);
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // Validators already ran — only proceed if page is valid
            if (!Page.IsValid) return;

            pnlError.Visible = false;

            var result = AuthService.Login(
                txtIdentifier.Text.Trim(),
                txtPassword.Text);

            if (!result.Succeeded)
            {
                ShowBannerError(pnlError, litError, result.Error);
                return;
            }

            // Update online status
            result.User.IsOnline  = true;
            result.User.LastSeenAt = DateTime.UtcNow;
            new Data.Repositories.UserRepository().Update(result.User);

            bool persistent = chkRemember.Checked;
            FormsAuthentication.SetAuthCookie(result.User.Username, persistent);

            string returnUrl = Request.QueryString["ReturnUrl"];
            if (!string.IsNullOrEmpty(returnUrl))
                Response.Redirect(returnUrl, true);
            else
                Response.Redirect("~/Chat.aspx", true);
        }

        protected void btnSendReset_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            // In a real app: send email. For now, just show success message.
            pnlResetSuccess.Visible = true;
        }
    }
}
