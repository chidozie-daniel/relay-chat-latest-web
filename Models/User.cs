using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RelayChat.Web.Models
{
    /// <summary>
    /// Represents a registered user account.
    /// Encapsulates all user-related data in one place (encapsulation).
    /// </summary>
    [Table("Users")]
    public class User
    {
        [Key]
        public int UserId { get; set; }

        [Required, MaxLength(50)]
        public string Username { get; set; }

        [Required, MaxLength(256)]
        public string Email { get; set; }

        [Required, MaxLength(256)]
        public string PasswordHash { get; set; }

        [Required, MaxLength(100)]
        public string DisplayName { get; set; }

        [MaxLength(200)]
        public string StatusMessage { get; set; }

        /// <summary>Hex color for avatar background, e.g. #5B5FEF</summary>
        [MaxLength(10)]
        public string AvatarColor { get; set; }

        public bool IsOnline { get; set; }

        public DateTime? LastSeenAt { get; set; }

        public DateTime CreatedAt { get; set; }

        /// <summary>"User" or "Administrator"</summary>
        [Required, MaxLength(20)]
        public string Role { get; set; }

        public bool IsSuspended { get; set; }

        /// <summary>Returns initials from DisplayName (e.g. "Noah Bennett" → "NB").</summary>
        public string GetInitials()
        {
            if (string.IsNullOrWhiteSpace(DisplayName)) return "?";
            var parts = DisplayName.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }

        /// <summary>Returns a safe display colour — falls back to signal-500 if none set.</summary>
        public string GetAvatarColor()
        {
            return string.IsNullOrWhiteSpace(AvatarColor) ? "#5B5FEF" : AvatarColor;
        }
    }
}
