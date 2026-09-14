using System.Collections.Generic;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public interface IChannelRepository
    {
        Channel GetById(int channelId);
        List<Channel> GetAll();
        List<Channel> GetByMember(int userId);
        void Add(Channel channel);
        void Update(Channel channel);
        void Delete(int channelId);
        void AddMember(int channelId, int userId);
        void RemoveMember(int channelId, int userId);
        bool IsMember(int channelId, int userId);
    }
}
