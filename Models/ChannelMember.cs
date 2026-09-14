using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RelayChat.Web.Models
{
    /// <summary>
    /// Join table linking a User to a Channel (membership).
    /// </summary>
    [Table("ChannelMembers")]
    public class ChannelMember
    {
        [Key]
        public int ChannelMemberId { get; set; }

        [Required]
        public int ChannelId { get; set; }

        [Required]
        public int UserId { get; set; }

        public DateTime JoinedAt { get; set; }

        // Navigation properties
        [ForeignKey("ChannelId")]
        public virtual Channel Channel { get; set; }

        [ForeignKey("UserId")]
        public virtual User User { get; set; }
    }
}
