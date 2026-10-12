using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public interface IMessageEditRepository
    {
        MessageEdit GetById(int editId);
        System.Collections.Generic.List<MessageEdit> GetByMessage(int messageId);
        void Add(MessageEdit edit);
    }
}