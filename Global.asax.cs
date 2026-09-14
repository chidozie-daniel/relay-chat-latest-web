using System;
using System.Web;
using System.Web.Routing;
using System.Web.UI;
using System.Data.Entity;
using RelayChat.Web.Data;
using RelayChat.Web.App_Start;

namespace RelayChat.Web
{
    public class Global : HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
            // Register jQuery for ASP.NET unobtrusive validation
            ScriptResourceMapping mapping = ScriptManager.ScriptResourceMapping;
            mapping.AddDefinition("jquery", new ScriptResourceDefinition
            {
                Path           = "https://cdn.jsdelivr.net/npm/jquery@3.7.0/dist/jquery.min.js",
                DebugPath      = "https://cdn.jsdelivr.net/npm/jquery@3.7.0/dist/jquery.js",
                CdnPath        = "https://cdn.jsdelivr.net/npm/jquery@3.7.0/dist/jquery.min.js",
                CdnDebugPath   = "https://cdn.jsdelivr.net/npm/jquery@3.7.0/dist/jquery.js",
                CdnSupportsSecureConnection = true,
                LoadSuccessExpression = "window.jQuery"
            });

            // Trigger EF6 database initializer on startup
            Database.SetInitializer(new RelayChatDbInitializer());
            using (var db = new RelayChatDbContext())
                db.Database.Initialize(false);

            RouteConfig.RegisterRoutes(RouteTable.Routes);
        }
    }
}
