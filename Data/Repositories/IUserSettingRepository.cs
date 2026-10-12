using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public interface IUserSettingRepository
    {
        UserSetting GetByUserId(int userId);
        void Add(UserSetting setting);
        void Update(UserSetting setting);
    }
}