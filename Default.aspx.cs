using System;
using System.Web.Security;
using System.Web.UI;

namespace RelayChat.Web
{
    public partial class Default : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // If already logged in, redirect straight to the chat workspace
            if (User.Identity.IsAuthenticated)
                Response.Redirect("~/Chat.aspx", true);
        }
    }
}
