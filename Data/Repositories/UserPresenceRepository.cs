using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public class UserPresenceRepository : IUserPresenceRepository
    {
        public UserPresence GetByUserId(int userId)
        {
            using (var db = new RelayChatDbContext())
                return db.UserPresences.FirstOrDefault(up => up.UserId == userId);
        }

        public void Add(UserPresence presence)
        {
            using (var db = new RelayChatDbContext())
            {
                db.UserPresences.Add(presence);
                db.SaveChanges();
            }
        }

        public void Update(UserPresence presence)
        {
            using (var db = new RelayChatDbContext())
            {
                db.Entry(presence).State = System.Data.Entity.EntityState.Modified;
                db.SaveChanges();
            }
        }

        public void Remove(int userId)
        {
            using (var db = new RelayChatDbContext())
            {
                var presence = db.UserPresences.FirstOrDefault(up => up.UserId == userId);
                if (presence != null)
                {
                    db.UserPresences.Remove(presence);
                    db.SaveChanges();
                }
            }
        }

        public List<UserPresence> GetOnlineUsers()
        {
            using (var db = new RelayChatDbContext())
                return db.UserPresences
                    .Include(up => up.User)
                    .Where(up => up.Status == "Online")
                    .ToList();
        }
    }
}