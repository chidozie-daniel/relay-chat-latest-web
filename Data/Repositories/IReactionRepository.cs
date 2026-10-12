using System.Collections.Generic;
using RelayChat.Web.Models;

namespace RelayChat.Web.Data.Repositories
{
    public interface IReactionRepository
    {
        Reaction GetById(int reactionId);
        List<Reaction> GetByMessage(int messageId);
        List<Reaction> GetByUser(int userId);
        void Add(Reaction reaction);
        void Remove(int reactionId);
        bool HasReacted(int messageId, int userId, string emoji);
        /// <summary>Adds the reaction if the user hasn't reacted with this emoji yet; removes it if they have.</summary>
        void Toggle(int messageId, int userId, string emoji);
    }
}
