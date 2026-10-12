using System.Collections.Generic;
using System.Linq;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public class UserSettingRepository : IUserSettingRepository
    {
        public UserSetting GetByUserId(int userId)
        {
            using (var db = new RelayChatDbContext())
                return db.UserSettings.FirstOrDefault(us => us.UserId == userId);
        }

        public void Add(UserSetting setting)
        {
            using (var db = new RelayChatDbContext())
            {
                db.UserSettings.Add(setting);
                db.SaveChanges();
            }
        }

        public void Update(UserSetting setting)
        {
            using (var db = new RelayChatDbContext())
            {
                db.Entry(setting).State = System.Data.Entity.EntityState.Modified;
                db.SaveChanges();
            }
        }
    }
}