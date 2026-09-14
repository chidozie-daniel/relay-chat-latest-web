using System;
using System.Security.Cryptography;

namespace RelayChat.Web.Services
{
    /// <summary>
    /// PBKDF2-SHA256 password hasher — salted, 100 000 iterations.
    /// Implements IPasswordHasher (polymorphism via interface).
    /// </summary>
    public class Pbkdf2PasswordHasher : IPasswordHasher
    {
        private const int SaltSize      = 16;
        private const int HashSize      = 32;
        private const int Iterations    = 100_000;

        public string HashPassword(string plainText)
        {
            byte[] salt = new byte[SaltSize];
            using (var rng = new RNGCryptoServiceProvider())
                rng.GetBytes(salt);

            byte[] hash = Pbkdf2(plainText, salt);
            byte[] result = new byte[SaltSize + HashSize];
            Buffer.BlockCopy(salt, 0, result, 0, SaltSize);
            Buffer.BlockCopy(hash, 0, result, SaltSize, HashSize);
            return Convert.ToBase64String(result);
        }

        public bool VerifyPassword(string plainText, string storedHash)
        {
            try
            {
                byte[] stored = Convert.FromBase64String(storedHash);
                if (stored.Length != SaltSize + HashSize) return false;

                byte[] salt = new byte[SaltSize];
                Buffer.BlockCopy(stored, 0, salt, 0, SaltSize);

                byte[] expected = new byte[HashSize];
                Buffer.BlockCopy(stored, SaltSize, expected, 0, HashSize);

                byte[] actual = Pbkdf2(plainText, salt);
                return SlowEquals(expected, actual);
            }
            catch { return false; }
        }

        private static byte[] Pbkdf2(string password, byte[] salt)
        {
            using (var prf = new Rfc2898DeriveBytes(password, salt, Iterations, HashAlgorithmName.SHA256))
                return prf.GetBytes(HashSize);
        }

        /// <summary>Constant-time comparison to prevent timing attacks.</summary>
        private static bool SlowEquals(byte[] a, byte[] b)
        {
            int diff = a.Length ^ b.Length;
            for (int i = 0; i < a.Length && i < b.Length; i++)
                diff |= a[i] ^ b[i];
            return diff == 0;
        }
    }
}
