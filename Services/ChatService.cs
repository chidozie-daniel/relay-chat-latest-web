using System;
using System.Collections.Generic;
using RelayChat.Web.Data.Repositories;
using RelayChat.Web.Models;

namespace RelayChat.Web.Services
{
    /// <summary>
    /// Business-logic layer for chat operations (DMs and channels).
    /// Injected with repository interfaces — no direct EF dependency.
    /// </summary>
    public class ChatService
    {
        private readonly IMessageRepository      _messages;
        private readonly IConversationRepository _conversations;
        private readonly IChannelRepository      _channels;
        private readonly IUserRepository         _users;

        public ChatService(
            IMessageRepository      messages,
            IConversationRepository conversations,
            IChannelRepository      channels,
            IUserRepository         users)
        {
            _messages      = messages      ?? throw new ArgumentNullException(nameof(messages));
            _conversations = conversations ?? throw new ArgumentNullException(nameof(conversations));
            _channels      = channels      ?? throw new ArgumentNullException(nameof(channels));
            _users         = users         ?? throw new ArgumentNullException(nameof(users));
        }

        // ── Direct messages ─────────────────────────────────────────────────

        public Conversation GetOrCreateConversation(int myId, int otherId)
            => _conversations.GetOrCreate(myId, otherId);

        public List<Conversation> GetMyConversations(int userId)
            => _conversations.GetByUser(userId);

        public List<Message> GetDirectMessages(int conversationId)
            => _messages.GetByConversation(conversationId);

        public void SendDirectMessage(int conversationId, int senderUserId, string body)
        {
            if (string.IsNullOrWhiteSpace(body)) return;
            _messages.Add(new Message
            {
                ConversationId = conversationId,
                SenderUserId   = senderUserId,
                Body           = body.Trim(),
                SentAt         = DateTime.UtcNow
            });
        }

        // ── Channels ────────────────────────────────────────────────────────

        public List<Channel> GetMyChannels(int userId)
            => _channels.GetByMember(userId);

        public Channel GetChannel(int channelId)
            => _channels.GetById(channelId);

        public Channel CreateChannel(string name, string topic, string icon, int ownerUserId)
        {
            var ch = new Channel
            {
                Name        = name.Trim(),
                Topic       = topic?.Trim(),
                Icon        = string.IsNullOrWhiteSpace(icon) ? "💬" : icon,
                OwnerUserId = ownerUserId,
                CreatedAt   = DateTime.UtcNow
            };
            _channels.Add(ch);
            _channels.AddMember(ch.ChannelId, ownerUserId);
            return ch;
        }

        public List<Message> GetChannelMessages(int channelId)
            => _messages.GetByChannel(channelId);

        public void SendChannelMessage(int channelId, int senderUserId, string body)
        {
            if (string.IsNullOrWhiteSpace(body)) return;
            _messages.Add(new Message
            {
                ChannelId    = channelId,
                SenderUserId = senderUserId,
                Body         = body.Trim(),
                SentAt       = DateTime.UtcNow
            });
        }

        // ── User search ─────────────────────────────────────────────────────

        public List<User> SearchUsers(string query)
            => _users.Search(query);
    }
}
