using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public interface IMentionRepository
    {
        Mention GetById(int mentionId);
        System.Collections.Generic.List<Mention> GetByUser(int userId, bool unreadOnly = false);
        System.Collections.Generic.List<Mention> GetByMessage(int messageId);
        void Add(Mention mention);
        void MarkRead(int mentionId);
        void MarkAllRead(int userId);
        int GetUnreadCount(int userId);
    }
}