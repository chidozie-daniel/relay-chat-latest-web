using System.Collections.Generic;
using System.Linq;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public class AttachmentRepository : IAttachmentRepository
    {
        public Attachment GetById(int attachmentId)
        {
            using (var db = new RelayChatDbContext())
                return db.Attachments.FirstOrDefault(a => a.AttachmentId == attachmentId);
        }

        public List<Attachment> GetByMessage(int messageId)
        {
            using (var db = new RelayChatDbContext())
                return db.Attachments
                    .Where(a => a.MessageId == messageId)
                    .OrderBy(a => a.UploadedAt)
                    .ToList();
        }

        public void Add(Attachment attachment)
        {
            using (var db = new RelayChatDbContext())
            {
                db.Attachments.Add(attachment);
                db.SaveChanges();
            }
        }

        public void Remove(int attachmentId)
        {
            using (var db = new RelayChatDbContext())
            {
                var attachment = db.Attachments.Find(attachmentId);
                if (attachment != null)
                {
                    db.Attachments.Remove(attachment);
                    db.SaveChanges();
                }
            }
        }
    }
}