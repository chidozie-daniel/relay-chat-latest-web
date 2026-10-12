using System.Collections.Generic;
using System.Data.Entity;
using System.Data.Entity.Migrations;
using System.Linq;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data
{
    /// <summary>
    /// EF6 database initializer — uses MigrateDatabaseToLatestVersion so the
    /// existing database is never dropped. New columns are added via automatic
    /// migrations, preserving all existing data.
    /// </summary>
    public class RelayChatDbInitializer
        : MigrateDatabaseToLatestVersion<RelayChatDbContext, RelayChatDbMigrationsConfig>
    {
    }

    /// <summary>
    /// EF6 automatic migrations configuration.
    /// AllowDataLoss = false keeps it safe — it will throw rather than silently
    /// delete a column that still has data.
    /// </summary>
    public sealed class RelayChatDbMigrationsConfig
        : DbMigrationsConfiguration<RelayChatDbContext>
    {
        public RelayChatDbMigrationsConfig()
        {
            AutomaticMigrationsEnabled     = true;
            AutomaticMigrationDataLossAllowed = false;
        }

        protected override void Seed(RelayChatDbContext context)
        {
            // Only seed the admin user if no users exist yet
            if (!context.Users.Any())
            {
                var hasher = new Services.Pbkdf2PasswordHasher();
                context.Users.AddOrUpdate(u => u.Username, new User
                {
                    Username     = "admin",
                    Email        = "admin@relaychat.app",
                    DisplayName  = "Administrator",
                    PasswordHash = hasher.HashPassword("Admin@1234"),
                    Role         = "Administrator",
                    AvatarColor  = "#5B5FEF",
                    IsOnline     = false,
                    IsSuspended  = false,
                    CreatedAt    = System.DateTime.UtcNow
                });
                context.SaveChanges();
            }
        }
    }
}
