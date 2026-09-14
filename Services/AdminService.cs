using System;
using System.Collections.Generic;
using RelayChat.Web.Data.Repositories;
using RelayChat.Web.Models;

namespace RelayChat.Web.Services
{
    /// <summary>
    /// Business-logic layer for admin operations (user management, moderation).
    /// </summary>
    public class AdminService
    {
        private readonly IUserRepository    _users;
        private readonly IChannelRepository _channels;

        public AdminService(IUserRepository users, IChannelRepository channels)
        {
            _users    = users    ?? throw new ArgumentNullException(nameof(users));
            _channels = channels ?? throw new ArgumentNullException(nameof(channels));
        }

        public List<User> GetAllUsers() => _users.GetAll();

        public List<User> SearchUsers(string query) => _users.Search(query);

        public List<Channel> GetAllChannels() => _channels.GetAll();

        public void SuspendUser(int userId)
        {
            var user = _users.GetById(userId);
            if (user == null) return;
            user.IsSuspended = true;
            _users.Update(user);
        }

        public void ReactivateUser(int userId)
        {
            var user = _users.GetById(userId);
            if (user == null) return;
            user.IsSuspended = false;
            _users.Update(user);
        }

        public void PromoteToAdmin(int userId)
        {
            var user = _users.GetById(userId);
            if (user == null) return;
            user.Role = "Administrator";
            _users.Update(user);
        }

        public int GetOnlineCount() => _users.GetAll().FindAll(u => u.IsOnline).Count;

        public int GetSuspendedCount() => _users.GetAll().FindAll(u => u.IsSuspended).Count;
    }
}
