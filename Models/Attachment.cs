using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RelayChat.Web.Models
{
    [Table("Attachments")]
    public class Attachment
    {
        [Key]
        public int AttachmentId { get; set; }

        [Required]
        public int MessageId { get; set; }

        [Required, MaxLength(255)]
        public string FileName { get; set; }

        [Required, MaxLength(100)]
        public string ContentType { get; set; }

        public long FileSize { get; set; }

        [Required, MaxLength(500)]
        public string StoragePath { get; set; }

        [MaxLength(500)]
        public string ThumbnailPath { get; set; }

        [MaxLength(20)]
        public string FileExtension { get; set; }

        public int? Width { get; set; }
        public int? Height { get; set; }
        public int? DurationSeconds { get; set; }

        public DateTime UploadedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey("MessageId")]
        public virtual Message Message { get; set; }
    }
}