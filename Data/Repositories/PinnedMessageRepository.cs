using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public class PinnedMessageRepository : IPinnedMessageRepository
    {
        public PinnedMessage GetById(int pinnedMessageId)
        {
            using (var db = new RelayChatDbContext())
                return db.PinnedMessages
                    .Include(pm => pm.Message)
                    .Include(pm => pm.Channel)
                    .Include(pm => pm.Conversation)
                    .Include(pm => pm.PinnedByUser)
                    .FirstOrDefault(pm => pm.PinnedMessageId == pinnedMessageId);
        }

        public List<PinnedMessage> GetByChannel(int channelId)
        {
            using (var db = new RelayChatDbContext())
                return db.PinnedMessages
                    .Include(pm => pm.Message)
                    .Include(pm => pm.PinnedByUser)
                    .Where(pm => pm.ChannelId == channelId)
                    .OrderByDescending(pm => pm.PinnedAt)
                    .ToList();
        }

        public List<PinnedMessage> GetByConversation(int conversationId)
        {
            using (var db = new RelayChatDbContext())
                return db.PinnedMessages
                    .Include(pm => pm.Message)
                    .Include(pm => pm.PinnedByUser)
                    .Where(pm => pm.ConversationId == conversationId)
                    .OrderByDescending(pm => pm.PinnedAt)
                    .ToList();
        }

        public void Add(PinnedMessage pinnedMessage)
        {
            using (var db = new RelayChatDbContext())
            {
                db.PinnedMessages.Add(pinnedMessage);
                db.SaveChanges();
            }
        }

        public void Remove(int pinnedMessageId)
        {
            using (var db = new RelayChatDbContext())
            {
                var pinned = db.PinnedMessages.Find(pinnedMessageId);
                if (pinned != null)
                {
                    db.PinnedMessages.Remove(pinned);
                    db.SaveChanges();
                }
            }
        }

        public bool IsPinned(int? channelId, int? conversationId, int messageId)
        {
            using (var db = new RelayChatDbContext())
                return db.PinnedMessages.Any(pm =>
                    pm.ChannelId == channelId &&
                    pm.ConversationId == conversationId &&
                    pm.MessageId == messageId);
        }
    }
}