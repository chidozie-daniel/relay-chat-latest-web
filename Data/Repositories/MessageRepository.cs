using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public class MessageRepository : IMessageRepository
    {
        public Message GetById(int messageId)
        {
            using (var db = new RelayChatDbContext())
                return db.Messages.Include(m => m.Sender).FirstOrDefault(m => m.MessageId == messageId);
        }

        public List<Message> GetByConversation(int conversationId)
        {
            using (var db = new RelayChatDbContext())
                return db.Messages
                    .Include(m => m.Sender)
                    .Where(m => m.ConversationId == conversationId)
                    .OrderBy(m => m.SentAt)
                    .ToList();
        }

        public List<Message> GetByChannel(int channelId)
        {
            using (var db = new RelayChatDbContext())
                return db.Messages
                    .Include(m => m.Sender)
                    .Where(m => m.ChannelId == channelId)
                    .OrderBy(m => m.SentAt)
                    .ToList();
        }

        public void Add(Message message)
        {
            using (var db = new RelayChatDbContext())
            {
                db.Messages.Add(message);
                db.SaveChanges();
            }
        }

        public void MarkDeleted(int messageId)
        {
            using (var db = new RelayChatDbContext())
            {
                var msg = db.Messages.Find(messageId);
                if (msg != null) { msg.IsDeleted = true; db.SaveChanges(); }
            }
        }
    }
}
