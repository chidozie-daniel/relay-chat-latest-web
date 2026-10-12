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
        public DbSet<UserSetting> UserSettings { get; set; }
        public DbSet<UserBlock> UserBlocks { get; set; }
        public DbSet<UserPresence> UserPresences { get; set; }
        public DbSet<Reaction> Reactions { get; set; }
        public DbSet<Attachment> Attachments { get; set; }
        public DbSet<Mention> Mentions { get; set; }
        public DbSet<MessageEdit> MessageEdits { get; set; }
        public DbSet<PinnedMessage> PinnedMessages { get; set; }
        public DbSet<ChannelInvite> ChannelInvites { get; set; }
        public DbSet<AuditLog> AuditLogs { get; set; }

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

            // UserSetting → User: one-to-one (unique FK), cascade delete
            modelBuilder.Entity<UserSetting>()
                .HasRequired(us => us.User)
                .WithMany()
                .HasForeignKey(us => us.UserId)
                .WillCascadeOnDelete(true);

            // UserBlock: composite unique index on BlockerUserId + BlockedUserId
            modelBuilder.Entity<UserBlock>()
                .HasRequired(ub => ub.Blocker)
                .WithMany()
                .HasForeignKey(ub => ub.BlockerUserId)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<UserBlock>()
                .HasRequired(ub => ub.Blocked)
                .WithMany()
                .HasForeignKey(ub => ub.BlockedUserId)
                .WillCascadeOnDelete(false);

            // UserPresence → User: one-to-one (unique FK), cascade delete
            modelBuilder.Entity<UserPresence>()
                .HasRequired(up => up.User)
                .WithMany()
                .HasForeignKey(up => up.UserId)
                .WillCascadeOnDelete(true);

            // Reaction → Message: cascade delete
            modelBuilder.Entity<Reaction>()
                .HasRequired(r => r.Message)
                .WithMany()
                .HasForeignKey(r => r.MessageId)
                .WillCascadeOnDelete(true);

            modelBuilder.Entity<Reaction>()
                .HasRequired(r => r.User)
                .WithMany()
                .HasForeignKey(r => r.UserId)
                .WillCascadeOnDelete(false);

            // Attachment → Message: cascade delete
            modelBuilder.Entity<Attachment>()
                .HasRequired(a => a.Message)
                .WithMany()
                .HasForeignKey(a => a.MessageId)
                .WillCascadeOnDelete(true);

            // Mention → Message: cascade delete
            modelBuilder.Entity<Mention>()
                .HasRequired(m => m.Message)
                .WithMany()
                .HasForeignKey(m => m.MessageId)
                .WillCascadeOnDelete(true);

            modelBuilder.Entity<Mention>()
                .HasRequired(m => m.MentionedUser)
                .WithMany()
                .HasForeignKey(m => m.MentionedUserId)
                .WillCascadeOnDelete(false);

            // MessageEdit → Message: cascade delete
            modelBuilder.Entity<MessageEdit>()
                .HasRequired(me => me.Message)
                .WithMany()
                .HasForeignKey(me => me.MessageId)
                .WillCascadeOnDelete(true);

            // PinnedMessage: optional Channel or Conversation, required Message
            modelBuilder.Entity<PinnedMessage>()
                .HasOptional(pm => pm.Channel)
                .WithMany()
                .HasForeignKey(pm => pm.ChannelId)
                .WillCascadeOnDelete(true);

            modelBuilder.Entity<PinnedMessage>()
                .HasOptional(pm => pm.Conversation)
                .WithMany()
                .HasForeignKey(pm => pm.ConversationId)
                .WillCascadeOnDelete(true);

            modelBuilder.Entity<PinnedMessage>()
                .HasRequired(pm => pm.Message)
                .WithMany()
                .HasForeignKey(pm => pm.MessageId)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<PinnedMessage>()
                .HasRequired(pm => pm.PinnedByUser)
                .WithMany()
                .HasForeignKey(pm => pm.PinnedByUserId)
                .WillCascadeOnDelete(false);

            // ChannelInvite → Channel: cascade delete
            modelBuilder.Entity<ChannelInvite>()
                .HasRequired(ci => ci.Channel)
                .WithMany()
                .HasForeignKey(ci => ci.ChannelId)
                .WillCascadeOnDelete(true);

            modelBuilder.Entity<ChannelInvite>()
                .HasRequired(ci => ci.Inviter)
                .WithMany()
                .HasForeignKey(ci => ci.InviterUserId)
                .WillCascadeOnDelete(false);

            modelBuilder.Entity<ChannelInvite>()
                .HasOptional(ci => ci.Invitee)
                .WithMany()
                .HasForeignKey(ci => ci.InviteeUserId)
                .WillCascadeOnDelete(false);

            // Message self-reference: thread replies point to a parent message
            modelBuilder.Entity<Message>()
                .HasOptional(m => m.ParentMessage)
                .WithMany()
                .HasForeignKey(m => m.ParentMessageId)
                .WillCascadeOnDelete(false);

            // AuditLog → Actor (User): set null on delete
            modelBuilder.Entity<AuditLog>()
                .HasOptional(al => al.Actor)
                .WithMany()
                .HasForeignKey(al => al.ActorUserId)
                .WillCascadeOnDelete(false);
        }
    }
}
