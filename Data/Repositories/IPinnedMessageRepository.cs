using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public interface IPinnedMessageRepository
    {
        PinnedMessage GetById(int pinnedMessageId);
        System.Collections.Generic.List<PinnedMessage> GetByChannel(int channelId);
        System.Collections.Generic.List<PinnedMessage> GetByConversation(int conversationId);
        void Add(PinnedMessage pinnedMessage);
        void Remove(int pinnedMessageId);
        bool IsPinned(int? channelId, int? conversationId, int messageId);
    }
}