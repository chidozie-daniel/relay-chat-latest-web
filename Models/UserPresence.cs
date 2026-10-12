using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RelayChat.Web.Models
{
    [Table("UserPresences")]
    public class UserPresence
    {
        [Key]
        public int UserPresenceId { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required, MaxLength(20)]
        public string Status { get; set; } = "Offline";

        [MaxLength(200)]
        public string CustomStatus { get; set; }

        public DateTime LastHeartbeat { get; set; } = DateTime.UtcNow;

        [MaxLength(500)]
        public string DeviceInfo { get; set; }

        [MaxLength(100)]
        public string IpAddress { get; set; }

        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey("UserId")]
        public virtual User User { get; set; }
    }
}