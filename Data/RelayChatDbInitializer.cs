using System.Collections.Generic;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data
{
    /// <summary>
    /// EF6 database initializer — creates the database and seeds a default
    /// Administrator account if the database does not yet exist.
    /// </summary>
    public class RelayChatDbInitializer
        : System.Data.Entity.CreateDatabaseIfNotExists<RelayChatDbContext>
    {
        protected override void Seed(RelayChatDbContext context)
        {
            var hasher = new Services.Pbkdf2PasswordHasher();

            // Seed admin user
            var admin = new User
            {
                Username    = "admin",
                Email       = "admin@relaychat.app",
                DisplayName = "Administrator",
                PasswordHash = hasher.HashPassword("Admin@1234"),
                Role        = "Administrator",
                AvatarColor = "#5B5FEF",
                IsOnline    = false,
                IsSuspended = false,
                CreatedAt   = System.DateTime.UtcNow
            };
            context.Users.Add(admin);
            context.SaveChanges();
        }
    }
}
