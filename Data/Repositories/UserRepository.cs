using System;
using System.Collections.Generic;
using System.Linq;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    /// <summary>
    /// EF6-backed implementation of IUserRepository (polymorphism —
    /// AuthService depends only on the interface, not this class).
    /// </summary>
    public class UserRepository : IUserRepository
    {
        public User GetById(int userId)
        {
            using (var db = new RelayChatDbContext())
                return db.Users.FirstOrDefault(u => u.UserId == userId);
        }

        public User GetByUsernameOrEmail(string usernameOrEmail)
        {
            if (string.IsNullOrWhiteSpace(usernameOrEmail)) return null;
            string lower = usernameOrEmail.Trim().ToLower();
            using (var db = new RelayChatDbContext())
                return db.Users.FirstOrDefault(u =>
                    u.Username.ToLower() == lower ||
                    u.Email.ToLower() == lower);
        }

        public bool IsUsernameTaken(string username)
        {
            string lower = username.Trim().ToLower();
            using (var db = new RelayChatDbContext())
                return db.Users.Any(u => u.Username.ToLower() == lower);
        }

        public bool IsEmailTaken(string email)
        {
            string lower = email.Trim().ToLower();
            using (var db = new RelayChatDbContext())
                return db.Users.Any(u => u.Email.ToLower() == lower);
        }

        public void Add(User user)
        {
            using (var db = new RelayChatDbContext())
            {
                db.Users.Add(user);
                db.SaveChanges();
            }
        }

        public void Update(User user)
        {
            using (var db = new RelayChatDbContext())
            {
                db.Entry(user).State = System.Data.Entity.EntityState.Modified;
                db.SaveChanges();
            }
        }

        public List<User> GetAll()
        {
            using (var db = new RelayChatDbContext())
                return db.Users.OrderBy(u => u.DisplayName).ToList();
        }

        public List<User> Search(string query)
        {
            string lower = (query ?? "").Trim().ToLower();
            using (var db = new RelayChatDbContext())
                return db.Users
                    .Where(u => u.Username.ToLower().Contains(lower) ||
                                u.DisplayName.ToLower().Contains(lower))
                    .OrderBy(u => u.DisplayName)
                    .ToList();
        }
    }
}
