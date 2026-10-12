using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public interface IUserPresenceRepository
    {
        UserPresence GetByUserId(int userId);
        void Add(UserPresence presence);
        void Update(UserPresence presence);
        void Remove(int userId);
        System.Collections.Generic.List<UserPresence> GetOnlineUsers();
    }
}