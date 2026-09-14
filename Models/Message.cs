using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RelayChat.Web.Models
{
    /// <summary>
    /// A single chat message — belongs to either a Conversation (DM) or a Channel.
    /// Exactly one of ConversationId / ChannelId will be non-null.
    /// </summary>
    [Table("Messages")]
    public class Message
    {
        [Key]
        public int MessageId { get; set; }

        [Required]
        public int SenderUserId { get; set; }

        /// <summary>Set for DM messages.</summary>
        public int? ConversationId { get; set; }

        /// <summary>Set for channel messages.</summary>
        public int? ChannelId { get; set; }

        [Required, MaxLength(4000)]
        public string Body { get; set; }

        public DateTime SentAt { get; set; }

        public bool IsDeleted { get; set; }

        // Navigation properties
        [ForeignKey("SenderUserId")]
        public virtual User Sender { get; set; }

        [ForeignKey("ConversationId")]
        public virtual Conversation Conversation { get; set; }

        [ForeignKey("ChannelId")]
        public virtual Channel Channel { get; set; }

        /// <summary>Returns display-safe body text, replacing deleted messages.</summary>
        public string GetDisplayBody()
        {
            return IsDeleted ? "This message was deleted." : Body;
        }

        /// <summary>Formatted sent time for the UI (e.g. "2:41 PM").</summary>
        public string GetFormattedTime()
        {
            return SentAt.ToLocalTime().ToString("h:mm tt");
        }
    }
}
