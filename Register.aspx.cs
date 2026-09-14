using System;
using System.Web.Security;
using System.Web.UI;
using RelayChat.Web.Common;
using RelayChat.Web.Data.Repositories;

namespace RelayChat.Web
{
    /// <summary>
    /// Register page. Inherits BasePage for AuthService.
    /// CustomValidator server-side callbacks enforce uniqueness (DB checks
    /// that cannot be expressed by standard validator controls).
    /// </summary>
    public partial class Register : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (User.Identity.IsAuthenticated)
                Response.Redirect("~/Chat.aspx", true);
        }

        /* ── CustomValidator callbacks ─────────────────────────────────── */

        protected void cvUsername_ServerValidate(object source, System.Web.UI.WebControls.ServerValidateEventArgs args)
        {
            args.IsValid = !new UserRepository().IsUsernameTaken(args.Value.Trim());
        }

        protected void cvEmail_ServerValidate(object source, System.Web.UI.WebControls.ServerValidateEventArgs args)
        {
            args.IsValid = !new UserRepository().IsEmailTaken(args.Value.Trim().ToLower());
        }

        protected void cvTerms_ServerValidate(object source, System.Web.UI.WebControls.ServerValidateEventArgs args)
        {
            args.IsValid = chkTerms.Checked;
        }

        /* ── Submit ─────────────────────────────────────────────────────── */

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            pnlError.Visible = false;

            var result = AuthService.Register(
                txtUsername.Text.Trim(),
                txtEmail.Text.Trim(),
                txtDisplayName.Text.Trim(),
                txtPassword.Text);

            if (!result.Succeeded)
            {
                ShowBannerError(pnlError, litError, result.Error);
                return;
            }

            // Sign the user in immediately after registration
            FormsAuthentication.SetAuthCookie(result.User.Username, false);
            Response.Redirect("~/Chat.aspx", true);
        }
    }
}
