using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RelayChat.Web.Models
{
    [Table("Reactions")]
    public class Reaction
    {
        [Key]
        public int ReactionId { get; set; }

        [Required]
        public int MessageId { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required, MaxLength(10)]
        public string Emoji { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey("MessageId")]
        public virtual Message Message { get; set; }

        [ForeignKey("UserId")]
        public virtual User User { get; set; }
    }
}