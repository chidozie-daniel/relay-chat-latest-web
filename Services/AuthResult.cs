using RelayChat.Web.Models;

namespace RelayChat.Web.Services
{
    /// <summary>
    /// Encapsulates the outcome of an auth operation.
    /// Uses a static factory pattern — callers read Result.Succeeded, never construct directly.
    /// </summary>
    public class AuthResult
    {
        public bool Succeeded  { get; private set; }
        public string Error    { get; private set; }
        public User   User     { get; private set; }

        private AuthResult() { }

        public static AuthResult Success(User user)
            => new AuthResult { Succeeded = true, User = user };

        public static AuthResult Failure(string error)
            => new AuthResult { Succeeded = false, Error = error };
    }
}
