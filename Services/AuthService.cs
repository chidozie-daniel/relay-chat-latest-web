using System;
using RelayChat.Web.Data.Repositories;
using RelayChat.Web.Models;

namespace RelayChat.Web.Services
{
    /// <summary>
    /// Business-logic layer for authentication.
    /// Depends only on IUserRepository and IPasswordHasher (abstraction).
    /// Composed in BasePage — no static state, one instance per request.
    /// </summary>
    public class AuthService
    {
        private readonly IUserRepository  _users;
        private readonly IPasswordHasher  _hasher;

        public AuthService(IUserRepository users, IPasswordHasher hasher)
        {
            _users  = users  ?? throw new ArgumentNullException(nameof(users));
            _hasher = hasher ?? throw new ArgumentNullException(nameof(hasher));
        }

        /// <summary>Validate credentials and return the matching user.</summary>
        public AuthResult Login(string usernameOrEmail, string plainTextPassword)
        {
            if (string.IsNullOrWhiteSpace(usernameOrEmail) || string.IsNullOrWhiteSpace(plainTextPassword))
                return AuthResult.Failure("Please enter your username/email and password.");

            User user = _users.GetByUsernameOrEmail(usernameOrEmail);
            if (user == null)
                return AuthResult.Failure("That username/email and password combination doesn't match our records.");

            if (user.IsSuspended)
                return AuthResult.Failure("This account has been suspended. Contact an administrator.");

            if (!_hasher.VerifyPassword(plainTextPassword, user.PasswordHash))
                return AuthResult.Failure("That username/email and password combination doesn't match our records.");

            return AuthResult.Success(user);
        }

        /// <summary>Create a new user account after all uniqueness checks.</summary>
        public AuthResult Register(string username, string email, string displayName, string plainTextPassword)
        {
            if (_users.IsUsernameTaken(username))
                return AuthResult.Failure("That username is already taken.");

            if (_users.IsEmailTaken(email))
                return AuthResult.Failure("An account with that email already exists.");

            var user = new User
            {
                Username     = username.Trim(),
                Email        = email.Trim().ToLower(),
                DisplayName  = displayName.Trim(),
                PasswordHash = _hasher.HashPassword(plainTextPassword),
                Role         = "User",
                AvatarColor  = PickAvatarColor(username),
                IsOnline     = false,
                IsSuspended  = false,
                CreatedAt    = DateTime.UtcNow
            };
            _users.Add(user);
            return AuthResult.Success(user);
        }

        /// <summary>Deterministically assigns one of the prototype's avatar colours.</summary>
        private static string PickAvatarColor(string username)
        {
            string[] palette = { "#5B5FEF", "#17BFB0", "#E4572E", "#9B51E0", "#F0A63E", "#EF4B5F" };
            int idx = Math.Abs(username.GetHashCode()) % palette.Length;
            return palette[idx];
        }
    }
}
