using System.Data.Entity;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data
{
    /// <summary>
    /// EF6 Code-First DbContext. Connection string name must match Web.config.
    /// </summary>
    public class RelayChatDbContext : DbContext
    {
        public RelayChatDbContext() : base("name=RelayChatDb") { }

        public DbSet<User> Users { get; set; }
        public DbSet<Conversation> Conversations { get; set; }
        public DbSet<Channel> Channels { get; set; }
        public DbSet<ChannelMember> ChannelMembers { get; set; }
        public DbSet<Message> Messages { get; set; }

        protected override void OnModelCreating(DbModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Disable cascade delete on Conversation → User (both FK on same table)
            modelBuilder.Entity<Conversation>()
                .HasRequired(c => c.UserA)
                .WithMany()
                .HasForeignKey(c => c.UserAId)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<Conversation>()
                .HasRequired(c => c.UserB)
                .WithMany()
                .HasForeignKey(c => c.UserBId)
                .WillCascadeOnDelete(false);

            // Disable cascade delete on Channel → Owner
            modelBuilder.Entity<Channel>()
                .HasRequired(c => c.Owner)
                .WithMany()
                .HasForeignKey(c => c.OwnerUserId)
                .WillCascadeOnDelete(false);

            // Disable cascade delete on Message → Sender
            modelBuilder.Entity<Message>()
                .HasRequired(m => m.Sender)
                .WithMany()
                .HasForeignKey(m => m.SenderUserId)
                .WillCascadeOnDelete(false);

            // ChannelMember → Channel: cascade allowed
            modelBuilder.Entity<ChannelMember>()
                .HasRequired(cm => cm.Channel)
                .WithMany(c => c.Members)
                .HasForeignKey(cm => cm.ChannelId)
                .WillCascadeOnDelete(true);
        }
    }
}
