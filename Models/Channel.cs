using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RelayChat.Web.Models
{
    /// <summary>
    /// Represents a group channel (e.g. #relay-core-team).
    /// </summary>
    [Table("Channels")]
    public class Channel
    {
        [Key]
        public int ChannelId { get; set; }

        [Required, MaxLength(100)]
        public string Name { get; set; }

        [MaxLength(300)]
        public string Topic { get; set; }

        [MaxLength(10)]
        public string Icon { get; set; }

        [Required]
        public int OwnerUserId { get; set; }

        public DateTime CreatedAt { get; set; }

        // Navigation properties
        [ForeignKey("OwnerUserId")]
        public virtual User Owner { get; set; }

        public virtual ICollection<ChannelMember> Members { get; set; }

        public Channel()
        {
            Members = new HashSet<ChannelMember>();
        }
    }
}
