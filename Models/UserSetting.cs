using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RelayChat.Web.Models
{
    [Table("UserSettings")]
    public class UserSetting
    {
        [Key]
        public int UserSettingId { get; set; }

        [Required]
        public int UserId { get; set; }

        [MaxLength(20)]
        public string Theme { get; set; } = "system";

        [MaxLength(10)]
        public string Language { get; set; } = "en-US";

        public bool EmailNotifications { get; set; } = true;
        public bool PushNotifications { get; set; } = true;
        public bool DesktopNotifications { get; set; } = true;
        public bool SoundNotifications { get; set; } = true;

        public bool ShowReadReceipts { get; set; } = true;
        public bool ShowTypingIndicator { get; set; } = true;
        public bool AutoDownloadMedia { get; set; } = true;

        [MaxLength(20)]
        public string MessageDisplay { get; set; } = "comfortable";

        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey("UserId")]
        public virtual User User { get; set; }
    }
}