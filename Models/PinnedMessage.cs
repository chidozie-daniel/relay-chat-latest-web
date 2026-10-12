using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RelayChat.Web.Models
{
    [Table("PinnedMessages")]
    public class PinnedMessage
    {
        [Key]
        public int PinnedMessageId { get; set; }

        public int? ChannelId { get; set; }
        public int? ConversationId { get; set; }

        [Required]
        public int MessageId { get; set; }

        [Required]
        public int PinnedByUserId { get; set; }

        public DateTime PinnedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey("ChannelId")]
        public virtual Channel Channel { get; set; }

        [ForeignKey("ConversationId")]
        public virtual Conversation Conversation { get; set; }

        [ForeignKey("MessageId")]
        public virtual Message Message { get; set; }

        [ForeignKey("PinnedByUserId")]
        public virtual User PinnedByUser { get; set; }
    }
}