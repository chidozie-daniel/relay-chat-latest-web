using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RelayChat.Web.Models
{
    [Table("AuditLogs")]
    public class AuditLog
    {
        [Key]
        public int AuditLogId { get; set; }

        public int? ActorUserId { get; set; }

        [Required, MaxLength(50)]
        public string Action { get; set; }

        [Required, MaxLength(50)]
        public string EntityType { get; set; }

        public int? EntityId { get; set; }

        [MaxLength(2000)]
        public string Details { get; set; }

        [MaxLength(45)]
        public string IpAddress { get; set; }

        [MaxLength(500)]
        public string UserAgent { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey("ActorUserId")]
        public virtual User Actor { get; set; }
    }
}