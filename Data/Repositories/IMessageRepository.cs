using System.Collections.Generic;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public interface IMessageRepository
    {
        Message GetById(int messageId);
        List<Message> GetByConversation(int conversationId);
        List<Message> GetByChannel(int channelId);
        void Add(Message message);
        void MarkDeleted(int messageId);
    }
}
