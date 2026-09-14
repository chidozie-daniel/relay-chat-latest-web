using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public interface IConversationRepository
    {
        Conversation GetById(int conversationId);
        Conversation GetByUsers(int userAId, int userBId);
        System.Collections.Generic.List<Conversation> GetByUser(int userId);
        Conversation GetOrCreate(int userAId, int userBId);
    }
}
