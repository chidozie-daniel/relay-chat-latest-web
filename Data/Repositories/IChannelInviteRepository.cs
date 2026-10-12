using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public interface IChannelInviteRepository
    {
        ChannelInvite GetById(int inviteId);
        ChannelInvite GetByCode(string inviteCode);
        System.Collections.Generic.List<ChannelInvite> GetByChannel(int channelId);
        System.Collections.Generic.List<ChannelInvite> GetByInviter(int inviterUserId);
        System.Collections.Generic.List<ChannelInvite> GetByInvitee(int inviteeUserId);
        void Add(ChannelInvite invite);
        void Update(ChannelInvite invite);
        void Remove(int inviteId);
    }
}