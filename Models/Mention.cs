using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RelayChat.Web.Models
{
    [Table("Mentions")]
    public class Mention
    {
        [Key]
        public int MentionId { get; set; }

        [Required]
        public int MessageId { get; set; }

        [Required]
        public int MentionedUserId { get; set; }

        public bool IsRead { get; set; } = false;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? ReadAt { get; set; }

        [ForeignKey("MessageId")]
        public virtual Message Message { get; set; }

        [ForeignKey("MentionedUserId")]
        public virtual User MentionedUser { get; set; }
    }
}