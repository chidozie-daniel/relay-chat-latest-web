using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    /// <summary>
    /// Contract for user persistence operations (abstraction / interface segregation).
    /// </summary>
    public interface IUserRepository
    {
        User GetById(int userId);
        User GetByUsernameOrEmail(string usernameOrEmail);
        bool IsUsernameTaken(string username);
        bool IsEmailTaken(string email);
        void Add(User user);
        void Update(User user);
        System.Collections.Generic.List<User> GetAll();
        System.Collections.Generic.List<User> Search(string query);
    }
}
