using System.Collections.Generic;
using System.Linq;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public class MessageEditRepository : IMessageEditRepository
    {
        public MessageEdit GetById(int editId)
        {
            using (var db = new RelayChatDbContext())
                return db.MessageEdits.FirstOrDefault(me => me.MessageEditId == editId);
        }

        public List<MessageEdit> GetByMessage(int messageId)
        {
            using (var db = new RelayChatDbContext())
                return db.MessageEdits
                    .Where(me => me.MessageId == messageId)
                    .OrderByDescending(me => me.EditedAt)
                    .ToList();
        }

        public void Add(MessageEdit edit)
        {
            using (var db = new RelayChatDbContext())
            {
                db.MessageEdits.Add(edit);
                db.SaveChanges();
            }
        }
    }
}