using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public class AuditLogRepository : IAuditLogRepository
    {
        public AuditLog GetById(int logId)
        {
            using (var db = new RelayChatDbContext())
                return db.AuditLogs
                    .Include(al => al.Actor)
                    .FirstOrDefault(al => al.AuditLogId == logId);
        }

        public List<AuditLog> GetByActor(int actorUserId)
        {
            using (var db = new RelayChatDbContext())
                return db.AuditLogs
                    .Include(al => al.Actor)
                    .Where(al => al.ActorUserId == actorUserId)
                    .OrderByDescending(al => al.CreatedAt)
                    .ToList();
        }

        public List<AuditLog> GetByEntity(string entityType, int entityId)
        {
            using (var db = new RelayChatDbContext())
                return db.AuditLogs
                    .Include(al => al.Actor)
                    .Where(al => al.EntityType == entityType && al.EntityId == entityId)
                    .OrderByDescending(al => al.CreatedAt)
                    .ToList();
        }

        public List<AuditLog> GetByAction(string action)
        {
            using (var db = new RelayChatDbContext())
                return db.AuditLogs
                    .Include(al => al.Actor)
                    .Where(al => al.Action == action)
                    .OrderByDescending(al => al.CreatedAt)
                    .ToList();
        }

        public List<AuditLog> GetByDateRange(System.DateTime from, System.DateTime to)
        {
            using (var db = new RelayChatDbContext())
                return db.AuditLogs
                    .Include(al => al.Actor)
                    .Where(al => al.CreatedAt >= from && al.CreatedAt <= to)
                    .OrderByDescending(al => al.CreatedAt)
                    .ToList();
        }

        public void Add(AuditLog log)
        {
            using (var db = new RelayChatDbContext())
            {
                db.AuditLogs.Add(log);
                db.SaveChanges();
            }
        }

        public List<AuditLog> GetAll()
        {
            using (var db = new RelayChatDbContext())
                return db.AuditLogs
                    .Include(al => al.Actor)
                    .OrderByDescending(al => al.CreatedAt)
                    .ToList();
        }
    }
}