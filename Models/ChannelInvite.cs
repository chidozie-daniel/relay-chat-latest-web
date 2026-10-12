using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RelayChat.Web.Models
{
    [Table("ChannelInvites")]
    public class ChannelInvite
    {
        [Key]
        public int ChannelInviteId { get; set; }

        [Required]
        public int ChannelId { get; set; }

        [Required]
        public int InviterUserId { get; set; }

        public int? InviteeUserId { get; set; }

        [MaxLength(50)]
        public string InviteCode { get; set; }

        [Required, MaxLength(20)]
        public string Status { get; set; } = "Pending";

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public DateTime? ExpiresAt { get; set; }
        public DateTime? RespondedAt { get; set; }

        [ForeignKey("ChannelId")]
        public virtual Channel Channel { get; set; }

        [ForeignKey("InviterUserId")]
        public virtual User Inviter { get; set; }

        [ForeignKey("InviteeUserId")]
        public virtual User Invitee { get; set; }
    }
}