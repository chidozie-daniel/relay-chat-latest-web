using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RelayChat.Web.Models
{
    [Table("UserBlocks")]
    public class UserBlock
    {
        [Key]
        public int UserBlockId { get; set; }

        [Required]
        public int BlockerUserId { get; set; }

        [Required]
        public int BlockedUserId { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey("BlockerUserId")]
        public virtual User Blocker { get; set; }

        [ForeignKey("BlockedUserId")]
        public virtual User Blocked { get; set; }
    }
}