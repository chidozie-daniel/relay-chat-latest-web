// Auto-generated designer file — updated to match Chat.aspx
namespace RelayChat.Web
{
    public partial class Chat
    {
        // Hidden fields
        protected global::System.Web.UI.WebControls.HiddenField hfCurrentUserId;
        protected global::System.Web.UI.WebControls.HiddenField hfCurrentUserName;
        protected global::System.Web.UI.WebControls.HiddenField hfCurrentUserInitials;
        protected global::System.Web.UI.WebControls.HiddenField hfCurrentUserColor;
        protected global::System.Web.UI.WebControls.HiddenField hfCurrentUserRole;

        // Hidden postback buttons
        protected global::System.Web.UI.WebControls.Button btnLoadConvo;
        protected global::System.Web.UI.WebControls.Button btnReact;
        protected global::System.Web.UI.WebControls.Button btnLoadThread;
        protected global::System.Web.UI.WebControls.Button btnDeleteMsg;

        // Rail
        protected global::System.Web.UI.UpdatePanel upRail;
        protected global::System.Web.UI.WebControls.Repeater rptDMs;
        protected global::System.Web.UI.WebControls.Repeater rptChannels;
        protected global::System.Web.UI.WebControls.Literal litFooterAvatar;
        protected global::System.Web.UI.WebControls.Literal litFooterName;
        protected global::System.Web.UI.WebControls.HyperLink lnkAdmin;
        protected global::System.Web.UI.WebControls.LinkButton btnSettings;
        protected global::System.Web.UI.WebControls.LinkButton btnLogout;

        // Notification tray
        protected global::System.Web.UI.UpdatePanel upNotifs;
        protected global::System.Web.UI.WebControls.Repeater rptNotifs;

        // Messages
        protected global::System.Web.UI.UpdatePanel upMessages;
        protected global::System.Web.UI.Timer tmrRefresh;
        protected global::System.Web.UI.WebControls.Repeater rptMessages;

        // Composer
        protected global::System.Web.UI.UpdatePanel upComposer;
        protected global::System.Web.UI.WebControls.TextBox txtMessage;
        protected global::System.Web.UI.WebControls.Button btnSend;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvMessage;

        // Thread offcanvas composer
        protected global::System.Web.UI.UpdatePanel upThreadComposer;
        protected global::System.Web.UI.WebControls.TextBox txtThreadReply;
        protected global::System.Web.UI.WebControls.Button btnThreadSend;

        // Info panel
        protected global::System.Web.UI.UpdatePanel upInfoPanel;
        protected global::System.Web.UI.WebControls.Literal litInfoPanel;

        // New conversation modal — DM search
        protected global::System.Web.UI.UpdatePanel upUserSearch;
        protected global::System.Web.UI.WebControls.TextBox txtUserSearch;
        protected global::System.Web.UI.WebControls.Repeater rptUserSearch;

        // New conversation modal — channel create
        protected global::System.Web.UI.WebControls.TextBox txtNewChannelName;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvChannelName;
        protected global::System.Web.UI.WebControls.TextBox txtNewChannelTopic;
        protected global::System.Web.UI.WebControls.Button btnCreateChannel;

        // Settings modal
        protected global::System.Web.UI.UpdatePanel upSettings;
        protected global::System.Web.UI.WebControls.TextBox txtSetDisplayName;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvSetDisplayName;
        protected global::System.Web.UI.WebControls.TextBox txtSetStatus;
        protected global::System.Web.UI.WebControls.Button btnSaveProfile;
        protected global::System.Web.UI.WebControls.Panel pnlSettingsSaved;
    }
}
