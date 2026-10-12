using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public interface IUserBlockRepository
    {
        UserBlock GetById(int userBlockId);
        UserBlock GetByUsers(int blockerUserId, int blockedUserId);
        System.Collections.Generic.List<UserBlock> GetByBlocker(int blockerUserId);
        System.Collections.Generic.List<UserBlock> GetByBlocked(int blockedUserId);
        void Add(UserBlock block);
        void Remove(int userBlockId);
        bool IsBlocked(int blockerUserId, int blockedUserId);
    }
}