using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public class ChannelRepository : IChannelRepository
    {
        public Channel GetById(int channelId)
        {
            using (var db = new RelayChatDbContext())
                return db.Channels
                    .Include(c => c.Owner)
                    .Include(c => c.Members.Select(m => m.User))
                    .FirstOrDefault(c => c.ChannelId == channelId);
        }

        public List<Channel> GetAll()
        {
            using (var db = new RelayChatDbContext())
                return db.Channels.Include(c => c.Owner).OrderBy(c => c.Name).ToList();
        }

        public List<Channel> GetByMember(int userId)
        {
            using (var db = new RelayChatDbContext())
                return db.Channels
                    .Include(c => c.Owner)
                    .Where(c => c.Members.Any(m => m.UserId == userId))
                    .OrderBy(c => c.Name)
                    .ToList();
        }

        public void Add(Channel channel)
        {
            using (var db = new RelayChatDbContext())
            {
                db.Channels.Add(channel);
                db.SaveChanges();
            }
        }

        public void Update(Channel channel)
        {
            using (var db = new RelayChatDbContext())
            {
                db.Entry(channel).State = EntityState.Modified;
                db.SaveChanges();
            }
        }

        public void Delete(int channelId)
        {
            using (var db = new RelayChatDbContext())
            {
                var ch = db.Channels.Find(channelId);
                if (ch != null) { db.Channels.Remove(ch); db.SaveChanges(); }
            }
        }

        public void AddMember(int channelId, int userId)
        {
            using (var db = new RelayChatDbContext())
            {
                if (!db.ChannelMembers.Any(cm => cm.ChannelId == channelId && cm.UserId == userId))
                {
                    db.ChannelMembers.Add(new ChannelMember
                    {
                        ChannelId = channelId,
                        UserId    = userId,
                        JoinedAt  = DateTime.UtcNow
                    });
                    db.SaveChanges();
                }
            }
        }

        public void RemoveMember(int channelId, int userId)
        {
            using (var db = new RelayChatDbContext())
            {
                var cm = db.ChannelMembers.FirstOrDefault(m => m.ChannelId == channelId && m.UserId == userId);
                if (cm != null) { db.ChannelMembers.Remove(cm); db.SaveChanges(); }
            }
        }

        public bool IsMember(int channelId, int userId)
        {
            using (var db = new RelayChatDbContext())
                return db.ChannelMembers.Any(cm => cm.ChannelId == channelId && cm.UserId == userId);
        }
    }
}
