using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public class ReactionRepository : IReactionRepository
    {
        public Reaction GetById(int reactionId)
        {
            using (var db = new RelayChatDbContext())
                return db.Reactions.Include(r => r.User).FirstOrDefault(r => r.ReactionId == reactionId);
        }

        public List<Reaction> GetByMessage(int messageId)
        {
            using (var db = new RelayChatDbContext())
                return db.Reactions
                    .Include(r => r.User)
                    .Where(r => r.MessageId == messageId)
                    .OrderBy(r => r.CreatedAt)
                    .ToList();
        }

        public List<Reaction> GetByUser(int userId)
        {
            using (var db = new RelayChatDbContext())
                return db.Reactions
                    .Include(r => r.Message)
                    .Where(r => r.UserId == userId)
                    .OrderByDescending(r => r.CreatedAt)
                    .ToList();
        }

        public void Add(Reaction reaction)
        {
            using (var db = new RelayChatDbContext())
            {
                db.Reactions.Add(reaction);
                db.SaveChanges();
            }
        }

        public void Remove(int reactionId)
        {
            using (var db = new RelayChatDbContext())
            {
                var reaction = db.Reactions.Find(reactionId);
                if (reaction != null)
                {
                    db.Reactions.Remove(reaction);
                    db.SaveChanges();
                }
            }
        }

        public bool HasReacted(int messageId, int userId, string emoji)
        {
            using (var db = new RelayChatDbContext())
                return db.Reactions.Any(r =>
                    r.MessageId == messageId && r.UserId == userId && r.Emoji == emoji);
        }

        public void Toggle(int messageId, int userId, string emoji)
        {
            using (var db = new RelayChatDbContext())
            {
                var existing = db.Reactions.FirstOrDefault(r =>
                    r.MessageId == messageId && r.UserId == userId && r.Emoji == emoji);

                if (existing != null)
                {
                    db.Reactions.Remove(existing);
                }
                else
                {
                    db.Reactions.Add(new Reaction
                    {
                        MessageId = messageId,
                        UserId    = userId,
                        Emoji     = emoji,
                        CreatedAt = System.DateTime.UtcNow
                    });
                }
                db.SaveChanges();
            }
        }
    }
}