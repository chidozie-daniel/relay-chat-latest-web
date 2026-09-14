using System.Web.UI;
using RelayChat.Web.Data.Repositories;
using RelayChat.Web.Services;

namespace RelayChat.Web.Common
{
    /// <summary>
    /// Root base class for all pages. Composes shared services via constructor
    /// injection pattern — every page gets a fresh instance per request.
    /// Inheritance hierarchy:  BasePage → SecurePage → AdminPage
    /// </summary>
    public class BasePage : Page
    {
        /// <summary>Available to all pages for login / register operations.</summary>
        protected AuthService AuthService { get; private set; }

        /// <summary>Available to all authenticated pages for chat operations.</summary>
        protected ChatService ChatService { get; private set; }

        protected BasePage()
        {
            // Compose the dependency graph manually (no DI container in Web Forms).
            IUserRepository         userRepo    = new UserRepository();
            IPasswordHasher         hasher      = new Pbkdf2PasswordHasher();
            IMessageRepository      msgRepo     = new MessageRepository();
            IConversationRepository convoRepo   = new ConversationRepository();
            IChannelRepository      channelRepo = new ChannelRepository();

            AuthService = new AuthService(userRepo, hasher);
            ChatService = new ChatService(msgRepo, convoRepo, channelRepo, userRepo);
        }

        /// <summary>
        /// Surfaces an error banner consistently across pages (polymorphism —
        /// derived pages can override for different presentation).
        /// </summary>
        protected virtual void ShowBannerError(
            System.Web.UI.WebControls.Panel   bannerPanel,
            System.Web.UI.WebControls.Literal bannerText,
            string message)
        {
            bannerText.Text    = System.Web.HttpUtility.HtmlEncode(message);
            bannerPanel.Visible = true;
        }
    }
}
