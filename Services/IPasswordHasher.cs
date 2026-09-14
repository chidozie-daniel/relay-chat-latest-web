namespace RelayChat.Web.Services
{
    /// <summary>
    /// Abstraction for password hashing — allows swapping the algorithm
    /// without touching AuthService (dependency inversion principle).
    /// </summary>
    public interface IPasswordHasher
    {
        string HashPassword(string plainText);
        bool VerifyPassword(string plainText, string hash);
    }
}
