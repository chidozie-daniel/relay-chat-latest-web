using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RelayChat.Web.Models
{
    /// <summary>
    /// Represents a direct-message conversation between exactly two users.
    /// </summary>
    [Table("Conversations")]
    public class Conversation
    {
        [Key]
        public int ConversationId { get; set; }

        [Required]
        public int UserAId { get; set; }

        [Required]
        public int UserBId { get; set; }

        public DateTime CreatedAt { get; set; }

        // Navigation properties
        [ForeignKey("UserAId")]
        public virtual User UserA { get; set; }

        [ForeignKey("UserBId")]
        public virtual User UserB { get; set; }
    }
}
