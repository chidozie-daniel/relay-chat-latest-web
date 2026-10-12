using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public class MentionRepository : IMentionRepository
    {
        public Mention GetById(int mentionId)
        {
            using (var db = new RelayChatDbContext())
                return db.Mentions.Include(m => m.Message).FirstOrDefault(m => m.MentionId == mentionId);
        }

        public List<Mention> GetByUser(int userId, bool unreadOnly = false)
        {
            using (var db = new RelayChatDbContext())
            {
                var query = db.Mentions
                    .Include(m => m.Message)
                    .Include(m => m.Message.Sender)
                    .Where(m => m.MentionedUserId == userId);

                if (unreadOnly)
                    query = query.Where(m => !m.IsRead);

                return query.OrderByDescending(m => m.CreatedAt).ToList();
            }
        }

        public List<Mention> GetByMessage(int messageId)
        {
            using (var db = new RelayChatDbContext())
                return db.Mentions
                    .Include(m => m.MentionedUser)
                    .Where(m => m.MessageId == messageId)
                    .ToList();
        }

        public void Add(Mention mention)
        {
            using (var db = new RelayChatDbContext())
            {
                db.Mentions.Add(mention);
                db.SaveChanges();
            }
        }

        public void MarkRead(int mentionId)
        {
            using (var db = new RelayChatDbContext())
            {
                var mention = db.Mentions.Find(mentionId);
                if (mention != null && !mention.IsRead)
                {
                    mention.IsRead = true;
                    mention.ReadAt = System.DateTime.UtcNow;
                    db.SaveChanges();
                }
            }
        }

        public void MarkAllRead(int userId)
        {
            using (var db = new RelayChatDbContext())
            {
                var mentions = db.Mentions
                    .Where(m => m.MentionedUserId == userId && !m.IsRead)
                    .ToList();

                foreach (var m in mentions)
                {
                    m.IsRead = true;
                    m.ReadAt = System.DateTime.UtcNow;
                }
                db.SaveChanges();
            }
        }

        public int GetUnreadCount(int userId)
        {
            using (var db = new RelayChatDbContext())
                return db.Mentions.Count(m => m.MentionedUserId == userId && !m.IsRead);
        }
    }
}