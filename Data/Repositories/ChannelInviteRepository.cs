using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public class ChannelInviteRepository : IChannelInviteRepository
    {
        public ChannelInvite GetById(int inviteId)
        {
            using (var db = new RelayChatDbContext())
                return db.ChannelInvites
                    .Include(ci => ci.Channel)
                    .Include(ci => ci.Inviter)
                    .Include(ci => ci.Invitee)
                    .FirstOrDefault(ci => ci.ChannelInviteId == inviteId);
        }

        public ChannelInvite GetByCode(string inviteCode)
        {
            using (var db = new RelayChatDbContext())
                return db.ChannelInvites
                    .Include(ci => ci.Channel)
                    .Include(ci => ci.Inviter)
                    .Include(ci => ci.Invitee)
                    .FirstOrDefault(ci => ci.InviteCode == inviteCode);
        }

        public List<ChannelInvite> GetByChannel(int channelId)
        {
            using (var db = new RelayChatDbContext())
                return db.ChannelInvites
                    .Include(ci => ci.Inviter)
                    .Include(ci => ci.Invitee)
                    .Where(ci => ci.ChannelId == channelId)
                    .OrderByDescending(ci => ci.CreatedAt)
                    .ToList();
        }

        public List<ChannelInvite> GetByInviter(int inviterUserId)
        {
            using (var db = new RelayChatDbContext())
                return db.ChannelInvites
                    .Include(ci => ci.Channel)
                    .Include(ci => ci.Invitee)
                    .Where(ci => ci.InviterUserId == inviterUserId)
                    .OrderByDescending(ci => ci.CreatedAt)
                    .ToList();
        }

        public List<ChannelInvite> GetByInvitee(int inviteeUserId)
        {
            using (var db = new RelayChatDbContext())
                return db.ChannelInvites
                    .Include(ci => ci.Channel)
                    .Include(ci => ci.Inviter)
                    .Where(ci => ci.InviteeUserId == inviteeUserId)
                    .OrderByDescending(ci => ci.CreatedAt)
                    .ToList();
        }

        public void Add(ChannelInvite invite)
        {
            using (var db = new RelayChatDbContext())
            {
                db.ChannelInvites.Add(invite);
                db.SaveChanges();
            }
        }

        public void Update(ChannelInvite invite)
        {
            using (var db = new RelayChatDbContext())
            {
                db.Entry(invite).State = System.Data.Entity.EntityState.Modified;
                db.SaveChanges();
            }
        }

        public void Remove(int inviteId)
        {
            using (var db = new RelayChatDbContext())
            {
                var invite = db.ChannelInvites.Find(inviteId);
                if (invite != null)
                {
                    db.ChannelInvites.Remove(invite);
                    db.SaveChanges();
                }
            }
        }
    }
}