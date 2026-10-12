using System.Collections.Generic;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public interface IMessageRepository
    {
        Message GetById(int messageId);
        List<Message> GetByConversation(int conversationId);
        List<Message> GetByChannel(int channelId);
        /// <summary>Returns all direct thread replies to a parent message.</summary>
        List<Message> GetReplies(int parentMessageId);
        void Add(Message message);
        void Update(Message message);
        void MarkDeleted(int messageId);
        /// <summary>Returns all messages currently flagged for moderation review.</summary>
        List<Message> GetFlagged();
        /// <summary>Clears the IsFlagged flag without deleting the message (dismiss action).</summary>
        void ClearFlag(int messageId);
    }
}
