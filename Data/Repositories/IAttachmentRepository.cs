using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public interface IAttachmentRepository
    {
        Attachment GetById(int attachmentId);
        System.Collections.Generic.List<Attachment> GetByMessage(int messageId);
        void Add(Attachment attachment);
        void Remove(int attachmentId);
    }
}