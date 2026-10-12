using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RelayChat.Web.Models
{
    [Table("MessageEdits")]
    public class MessageEdit
    {
        [Key]
        public int MessageEditId { get; set; }

        [Required]
        public int MessageId { get; set; }

        [Required, MaxLength(4000)]
        public string PreviousBody { get; set; }

        public DateTime EditedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey("MessageId")]
        public virtual Message Message { get; set; }
    }
}