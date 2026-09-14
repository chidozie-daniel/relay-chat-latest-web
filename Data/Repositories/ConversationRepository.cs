using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public class ConversationRepository : IConversationRepository
    {
        public Conversation GetById(int conversationId)
        {
            using (var db = new RelayChatDbContext())
                return db.Conversations
                    .Include(c => c.UserA)
                    .Include(c => c.UserB)
                    .FirstOrDefault(c => c.ConversationId == conversationId);
        }

        public Conversation GetByUsers(int userAId, int userBId)
        {
            using (var db = new RelayChatDbContext())
                return db.Conversations
                    .Include(c => c.UserA)
                    .Include(c => c.UserB)
                    .FirstOrDefault(c =>
                        (c.UserAId == userAId && c.UserBId == userBId) ||
                        (c.UserAId == userBId && c.UserBId == userAId));
        }

        public List<Conversation> GetByUser(int userId)
        {
            using (var db = new RelayChatDbContext())
                return db.Conversations
                    .Include(c => c.UserA)
                    .Include(c => c.UserB)
                    .Where(c => c.UserAId == userId || c.UserBId == userId)
                    .ToList();
        }

        public Conversation GetOrCreate(int userAId, int userBId)
        {
            var existing = GetByUsers(userAId, userBId);
            if (existing != null) return existing;

            using (var db = new RelayChatDbContext())
            {
                var convo = new Conversation
                {
                    UserAId   = userAId,
                    UserBId   = userBId,
                    CreatedAt = DateTime.UtcNow
                };
                db.Conversations.Add(convo);
                db.SaveChanges();
                return convo;
            }
        }
    }
}
