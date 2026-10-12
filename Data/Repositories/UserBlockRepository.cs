using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public class UserBlockRepository : IUserBlockRepository
    {
        public UserBlock GetById(int userBlockId)
        {
            using (var db = new RelayChatDbContext())
                return db.UserBlocks.FirstOrDefault(ub => ub.UserBlockId == userBlockId);
        }

        public UserBlock GetByUsers(int blockerUserId, int blockedUserId)
        {
            using (var db = new RelayChatDbContext())
                return db.UserBlocks.FirstOrDefault(ub =>
                    ub.BlockerUserId == blockerUserId && ub.BlockedUserId == blockedUserId);
        }

        public List<UserBlock> GetByBlocker(int blockerUserId)
        {
            using (var db = new RelayChatDbContext())
                return db.UserBlocks
                    .Include(ub => ub.Blocked)
                    .Where(ub => ub.BlockerUserId == blockerUserId)
                    .ToList();
        }

        public List<UserBlock> GetByBlocked(int blockedUserId)
        {
            using (var db = new RelayChatDbContext())
                return db.UserBlocks
                    .Include(ub => ub.Blocker)
                    .Where(ub => ub.BlockedUserId == blockedUserId)
                    .ToList();
        }

        public void Add(UserBlock block)
        {
            using (var db = new RelayChatDbContext())
            {
                db.UserBlocks.Add(block);
                db.SaveChanges();
            }
        }

        public void Remove(int userBlockId)
        {
            using (var db = new RelayChatDbContext())
            {
                var block = db.UserBlocks.Find(userBlockId);
                if (block != null)
                {
                    db.UserBlocks.Remove(block);
                    db.SaveChanges();
                }
            }
        }

        public bool IsBlocked(int blockerUserId, int blockedUserId)
        {
            using (var db = new RelayChatDbContext())
                return db.UserBlocks.Any(ub =>
                    ub.BlockerUserId == blockerUserId && ub.BlockedUserId == blockedUserId);
        }
    }
}