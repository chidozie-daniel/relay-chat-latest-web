using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public interface IAuditLogRepository
    {
        AuditLog GetById(int logId);
        System.Collections.Generic.List<AuditLog> GetByActor(int actorUserId);
        System.Collections.Generic.List<AuditLog> GetByEntity(string entityType, int entityId);
        System.Collections.Generic.List<AuditLog> GetByAction(string action);
        System.Collections.Generic.List<AuditLog> GetByDateRange(System.DateTime from, System.DateTime to);
        void Add(AuditLog log);
        System.Collections.Generic.List<AuditLog> GetAll();
    }
}