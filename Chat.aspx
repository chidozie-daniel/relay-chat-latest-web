<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Chat.aspx.cs" Inherits="RelayChat.Web.Chat" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Relay Chat</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@500;600;700;800&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="<%=ResolveUrl("~/Content/css/site.css")%>" rel="stylesheet" />
</head>
<body>
<form id="form1" runat="server">
<asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true" />

<!-- Hidden fields for passing server data to JS -->
<asp:HiddenField ID="hfCurrentUserId"       runat="server" />
<asp:HiddenField ID="hfCurrentUserName"     runat="server" />
<asp:HiddenField ID="hfCurrentUserInitials" runat="server" />
<asp:HiddenField ID="hfCurrentUserColor"    runat="server" />
<asp:HiddenField ID="hfCurrentUserRole"     runat="server" />
<!-- Hidden postback button — triggered by JS selectConvo() to load a conversation -->
<asp:Button ID="btnLoadConvo"   runat="server" style="display:none;" OnClick="btnLoadConvo_Click"   CausesValidation="false" />
<!-- Hidden postback button — triggered by JS postReaction() -->
<asp:Button ID="btnReact"       runat="server" style="display:none;" OnClick="btnReact_Click"       CausesValidation="false" />
<!-- Hidden postback button — triggered by JS openThread() -->
<asp:Button ID="btnLoadThread"  runat="server" style="display:none;" OnClick="btnLoadThread_Click"  CausesValidation="false" />
<!-- Hidden postback button — triggered by JS deleteMessage() -->
<asp:Button ID="btnDeleteMsg"   runat="server" style="display:none;" OnClick="btnDeleteMsg_Click"   CausesValidation="false" />

<div class="app-shell">

  <!-- ── RAIL (sidebar) ────────────────────────────────────────────── -->
  <aside class="rail" id="rail">
    <div class="rail-head">
      <div class="rail-head-top">
        <div class="brand-mark">
          <svg viewBox="0 0 24 24" fill="none"><path d="M4 12c0-1.5 1-2.5 2.5-2.5S9 10.5 9 12s1 2.5 2.5 2.5S14 13.5 14 12s1-2.5 2.5-2.5S19 10.5 19 12" stroke="white" stroke-width="2" stroke-linecap="round"/></svg>
        </div>
        <span class="brand-word text-white fs-5 flex-grow-1">Relay</span>
        <div class="position-relative">
          <button class="icon-btn-dark" id="notifBtn" aria-label="Notifications">
            <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 8a6 6 0 1 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
            <span id="notifDot" style="position:absolute;top:5px;right:5px;width:7px;height:7px;border-radius:50%;background:var(--signal-500);border:1.5px solid var(--ink-950);display:none;"></span>
          </button>
          <!-- Notification tray -->
          <div class="notif-tray d-none" id="notifTray">
            <div class="d-flex align-items-center justify-content-between p-3" style="border-bottom:1px solid var(--line);">
              <strong class="font-display" style="font-size:.9rem;">Notifications</strong>
              <button id="markAllReadBtn" class="icon-btn" style="width:auto;height:auto;padding:.2rem .6rem;font-size:.75rem;font-family:var(--font-display);font-weight:600;color:var(--signal-500);">Mark all read</button>
            </div>
            <asp:UpdatePanel ID="upNotifs" runat="server" UpdateMode="Conditional">
              <ContentTemplate>
                <div style="max-height:340px;overflow-y:auto;" class="thin-scroll" id="notifList">
                  <asp:Repeater ID="rptNotifs" runat="server">
                    <ItemTemplate>
                      <div class="notif-row <%# (bool)Eval("IsRead") ? "" : "unread" %>"
                           data-convo-type="<%# Eval("ConvoType") %>"
                           data-convo-id="<%# Eval("ConvoId") %>">
                        <div class="avatar" style="width:34px;height:34px;background:<%# Eval("SenderColor") %>;font-size:.78rem;flex-shrink:0;">
                          <%# Eval("SenderInitials") %>
                        </div>
                        <div style="min-width:0;flex:1;">
                          <div class="d-flex justify-content-between">
                            <span style="font-size:.8rem;font-weight:600;"><%# System.Web.HttpUtility.HtmlEncode(Eval("FromName").ToString()) %></span>
                            <span class="font-mono" style="font-size:.66rem;color:var(--ash-400);"><%# Eval("TimeAgo") %></span>
                          </div>
                          <div style="font-size:.78rem;color:var(--ash-500);overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                            <%# System.Web.HttpUtility.HtmlEncode(Eval("PreviewText").ToString()) %>
                          </div>
                        </div>
                      </div>
                    </ItemTemplate>
                  </asp:Repeater>
                </div>
              </ContentTemplate>
            </asp:UpdatePanel>
          </div>
        </div>
        <button class="icon-btn-dark" id="newConvoBtn" aria-label="New conversation"
            data-bs-toggle="modal" data-bs-target="#newConvoModal">
          <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M12 5v14M5 12h14"/></svg>
        </button>
      </div>

      <!-- Search -->
      <div class="rail-search">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/></svg>
        <input id="railSearch" placeholder="Search conversations…" />
      </div>

      <!-- Filter tabs -->
      <div class="rail-tabs">
        <button class="rail-tab active" data-filter="all">All</button>
        <button class="rail-tab" data-filter="direct">DMs</button>
        <button class="rail-tab" data-filter="channels">Channels</button>
        <button class="rail-tab" data-filter="unread">Unread</button>
      </div>
    </div>

    <!-- Conversation list — rendered server-side, refreshed via UpdatePanel -->
    <asp:UpdatePanel ID="upRail" runat="server" UpdateMode="Conditional">
      <ContentTemplate>
        <div class="rail-list thin-scroll" id="railList">
          <div class="rail-section" id="railSectionPinned" data-section="pinned" style="display:none;">
            <div class="rail-section-label" style="cursor:default;">Pinned</div>
            <div id="pinnedList"></div>
          </div>
          <div class="rail-section" id="railSectionDMs" data-section="dms">
            <button type="button" class="rail-section-label" onclick="toggleRailSection('dms')">
              <svg class="chev" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="M9 18l6-6-6-6"/></svg>
              Direct Messages
            </button>
            <asp:Repeater ID="rptDMs" runat="server" OnItemCommand="rptDMs_ItemCommand">
            <ItemTemplate>
              <button class="rail-item <%# (int)Eval("ConversationId") == SelectedConversationId && !IsChannel ? "active" : "" %>"
                data-id="dm_<%# Eval("ConversationId") %>"
                data-type="dm"
                data-unread="<%# Eval("UnreadCount") %>"
                onclick="selectConvo('dm', <%# Eval("ConversationId") %>); return false;">
                <div class="avatar-wrap">
                  <div class="avatar" style="width:36px;height:36px;background:<%# Eval("OtherUser.AvatarColor") %>;font-size:.85rem;">
                    <%# Eval("OtherUser.GetInitials()") %>
                  </div>
                  <span class="presence <%# (bool)Eval("OtherUser.IsOnline") ? "online" : "offline" %>"></span>
                </div>
                <div class="meta">
                  <div class="meta-top">
                    <span class="name"><%# System.Web.HttpUtility.HtmlEncode(Eval("OtherUser.DisplayName").ToString()) %></span>
                    <span class="time"><%# Eval("LastMessageTime") %></span>
                  </div>
                  <div class="preview-row">
                    <span class="preview"><%# System.Web.HttpUtility.HtmlEncode(Eval("LastMessagePreview").ToString()) %></span>
                    <%# (int)Eval("UnreadCount") > 0 ? "<span class=\"unread-pill\">" + Eval("UnreadCount") + "</span>" : "" %>
                  </div>
                </div>
              </button>
            </ItemTemplate>
          </asp:Repeater>
          </div>

          <div class="rail-section" id="railSectionChannels" data-section="channels">
            <button type="button" class="rail-section-label" onclick="toggleRailSection('channels')">
              <svg class="chev" width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3"><path d="M9 18l6-6-6-6"/></svg>
              Channels
            </button>
            <asp:Repeater ID="rptChannels" runat="server" OnItemCommand="rptChannels_ItemCommand">
            <ItemTemplate>
              <button class="rail-item <%# (int)Eval("ChannelId") == SelectedChannelId && IsChannel ? "active" : "" %>"
                data-id="ch_<%# Eval("ChannelId") %>"
                data-type="channel"
                data-unread="<%# Eval("UnreadCount") %>"
                onclick="selectConvo('channel', <%# Eval("ChannelId") %>); return false;">
                <div class="channel-icon"><%# Eval("Icon") %></div>
                <div class="meta">
                  <div class="meta-top">
                    <span class="name">#<%# System.Web.HttpUtility.HtmlEncode(Eval("Name").ToString()) %></span>
                    <span class="time"><%# Eval("LastMessageTime") %></span>
                  </div>
                  <div class="preview-row">
                    <span class="preview"><%# System.Web.HttpUtility.HtmlEncode(Eval("LastMessagePreview").ToString()) %></span>
                    <%# (int)Eval("UnreadCount") > 0 ? "<span class=\"unread-pill\">" + Eval("UnreadCount") + "</span>" : "" %>
                  </div>
                </div>
              </button>
            </ItemTemplate>
          </asp:Repeater>
          </div>
          <div class="d-none" id="railEmptyState"></div>
        </div>
      </ContentTemplate>
    </asp:UpdatePanel>

    <!-- Rail footer -->
    <div class="rail-foot">
      <div class="avatar-wrap">
        <asp:Literal ID="litFooterAvatar" runat="server" />
        <span class="presence online"></span>
      </div>
      <div class="flex-grow-1" style="min-width:0;">
        <div class="name"><asp:Literal ID="litFooterName" runat="server" /></div>
        <div class="status-text">● Active</div>
      </div>
      <asp:HyperLink ID="lnkAdmin" runat="server" NavigateUrl="~/Admin/AdminDashboard.aspx"
          CssClass="icon-btn-dark" title="Admin console" Visible="false">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z"/></svg>
      </asp:HyperLink>
      <asp:LinkButton ID="btnSettings" runat="server" CssClass="icon-btn-dark" title="Settings"
          data-bs-toggle="modal" data-bs-target="#settingsModal" OnClientClick="return false;">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9"/></svg>
      </asp:LinkButton>
      <asp:LinkButton ID="btnLogout" runat="server" CssClass="icon-btn-dark" title="Log out"
          OnClick="btnLogout_Click" CausesValidation="false" style="background:none;border:none;">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="M16 17l5-5-5-5"/><path d="M21 12H9"/></svg>
      </asp:LinkButton>
    </div>
  </aside>

  <!-- ── CONVERSATION COLUMN ───────────────────────────────────────── -->
  <section class="convo-col" id="convoCol">

    <!-- Reconnect banner (cosmetic) -->
    <div class="conn-banner" id="connBanner"></div>

    <!-- Conversation header -->
    <div class="convo-head" id="convoHead">
      <button class="icon-btn back-btn" id="backBtn" aria-label="Back">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
      </button>
      <div class="avatar-wrap on-paper" id="convoAvatarWrap"></div>
      <div class="flex-grow-1" style="min-width:0;">
        <div class="title" id="convoTitle">Select a conversation</div>
        <div class="subtitle" id="convoSubtitle">Choose a DM or channel to get started</div>
      </div>
      <div id="convoActions" class="d-flex align-items-center gap-1">
        <!-- Populated by JS once a conversation is selected -->
      </div>
    </div>

    <!-- In-conversation search bar (hidden until toggled) -->
    <div class="px-3 py-2 bg-white border-bottom d-none" id="inConvoSearchBar" style="border-color:var(--line) !important;">
      <div class="input-wrap">
        <span class="field-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/></svg></span>
        <input id="inConvoSearchInput" class="field-input" placeholder="Search this conversation…" style="padding-top:.5rem;padding-bottom:.5rem;" />
      </div>
    </div>

    <!-- Message area — UpdatePanel for auto-refresh -->
    <asp:UpdatePanel ID="upMessages" runat="server" UpdateMode="Conditional">
      <ContentTemplate>
        <asp:Timer ID="tmrRefresh" runat="server" Interval="3000" OnTick="tmrRefresh_Tick" Enabled="false" />
        <div class="msg-scroll thin-scroll" id="msgScroll">
          <asp:Repeater ID="rptMessages" runat="server">
            <HeaderTemplate>
              <div class="date-sep"><div class="line"></div><span>Today</span><div class="line"></div></div>
            </HeaderTemplate>
            <ItemTemplate>
              <div class="msg-row <%# (bool)Eval("IsOwn") ? "own" : "" %> <%# (bool)Eval("IsTight") ? "tight" : "" %>" data-msg-id="<%# Eval("MessageId") %>">
                <!-- Hover action bar -->
                <%# (bool)Eval("IsDeleted") ? "" : BuildHoverBar((int)Eval("MessageId"), (bool)Eval("IsOwn")) %>
                <!-- Avatar (other users only) / spacer for tight groups -->
                <%# (bool)Eval("IsOwn") ? "" : ((bool)Eval("IsTight") ? "<div class=\"spacer-avatar\"></div>" : "<div class=\"avatar\" style=\"width:30px;height:30px;background:" + Eval("SenderColor") + ";font-size:.7rem;flex-shrink:0;\">" + Eval("SenderInitials") + "</div>") %>
                <div class="msg-col">
                  <%# ((bool)Eval("IsOwn") || (bool)Eval("IsTight")) ? "" : "<div class=\"msg-sender\">" + System.Web.HttpUtility.HtmlEncode(Eval("SenderName").ToString()) + "</div>" %>
                  <div class="bubble <%# (bool)Eval("IsDeleted") ? "msg-deleted" : "" %>">
                    <%# System.Web.HttpUtility.HtmlEncode(Eval("DisplayBody").ToString()) %>
                  </div>
                  <!-- Thread link -->
                  <%# (int)Eval("ReplyCount") > 0 ? BuildThreadLink((int)Eval("MessageId"), (int)Eval("ReplyCount")) : "" %>
                  <!-- Reactions row -->
                  <%# (bool)Eval("IsDeleted") ? "" : BuildReactionsHtml((int)Eval("MessageId")) %>
                  <div class="msg-foot">
                    <span class="t"><%# Eval("FormattedTime") %></span>
                    <%# (bool)Eval("IsOwn") ? "<span class=\"msg-read-tick\">" + BuildReadTick((bool)Eval("IsRead")) + "</span>" : "" %>
                  </div>
                </div>
              </div>
            </ItemTemplate>
          </asp:Repeater>
          <!-- Empty conversation state (toggled by JS) -->
          <div class="empty-state" id="noMessagesState" style="display:none;min-height:240px;">
            <div class="ico-wrap"><svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></div>
            <p style="color:var(--ash-800);font-weight:600;font-size:.95rem;margin-bottom:.25rem;">No messages yet</p>
            <p style="color:var(--ash-500);font-size:.85rem;">Say hello to start the conversation.</p>
          </div>
          <!-- Typing indicator placeholder (shown/hidden by JS) -->
          <div id="typingRow" style="display:none;" class="msg-row">
            <div class="typing-bubble"><i></i><i></i><i></i></div>
          </div>
          <!-- In-conversation search: no matches -->
          <div class="empty-state d-none" id="searchEmptyState" style="min-height:200px;">
            <div class="ico-wrap"><svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/></svg></div>
            <p style="color:var(--ash-500);font-size:.9rem;">No messages match your search.</p>
          </div>
        </div>
      </ContentTemplate>
    </asp:UpdatePanel>

    <!-- Message composer -->
    <div class="composer-wrap" id="composerWrap" style="display:none;">
      <div class="composer">
        <div class="composer-toolbar">
          <button type="button" class="icon-btn" title="Bold" data-fmt="bold"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><path d="M6 4h8a4 4 0 0 1 0 8H6zM6 12h9a4 4 0 0 1 0 8H6z"/></svg></button>
          <button type="button" class="icon-btn" title="Italic" data-fmt="italic"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><line x1="19" y1="4" x2="10" y2="4"/><line x1="14" y1="20" x2="5" y2="20"/><line x1="15" y1="4" x2="9" y2="20"/></svg></button>
          <button type="button" class="icon-btn" title="Code" data-fmt="code"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg></button>
          <button type="button" class="icon-btn" title="Link" data-fmt="link"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/></svg></button>
          <div style="width:1px;height:16px;background:var(--line);margin:0 .3rem;"></div>
          <button type="button" class="icon-btn" title="Attach file" id="attachBtn">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2"><path d="m21.44 11.05-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48"/></svg>
          </button>
        </div>
        <asp:UpdatePanel ID="upComposer" runat="server" UpdateMode="Conditional">
          <ContentTemplate>
            <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine"
                placeholder="Message…" Rows="1"
                style="width:100%;border:none;outline:none;resize:none;padding:.6rem .95rem;font-size:.88rem;font-family:inherit;color:var(--ash-800);max-height:120px;display:block;background:transparent;" />
            <div class="composer-bottom">
              <div class="d-flex gap-1" style="position:relative;">
                <button type="button" class="icon-btn" id="emojiBtn" title="Emoji">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg>
                </button>
                <!-- Emoji picker popup -->
                <div class="emoji-pop d-none" id="emojiPop">
                  <div class="emoji-cat-tabs" id="emojiCatTabs"></div>
                  <div class="emoji-grid" id="emojiGrid"></div>
                </div>
                <button type="button" class="icon-btn" id="voiceBtn" title="Voice message">
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 1a3 3 0 0 0-3 3v8a3 3 0 0 0 6 0V4a3 3 0 0 0-3-3Z"/><path d="M19 10v2a7 7 0 0 1-14 0v-2M12 19v3"/></svg>
                </button>
              </div>
              <asp:Button ID="btnSend" runat="server" Text="Send ➤"
                  CssClass="btn-signal" style="padding:.5rem 1.1rem;font-size:.83rem;"
                  OnClick="btnSend_Click" ValidationGroup="MessageGroup" />
            </div>
          </ContentTemplate>
        </asp:UpdatePanel>
        <asp:RequiredFieldValidator ID="rfvMessage" runat="server"
            ControlToValidate="txtMessage"
            ErrorMessage="Type a message first."
            Display="Dynamic" CssClass="val-error px-3 pb-2"
            ValidationGroup="MessageGroup" />
      </div>
      <p class="text-center mt-1" style="font-size:.68rem;color:var(--ash-400);font-family:var(--font-mono);">Enter to send · Shift+Enter for new line</p>
    </div>
  </section>

  <!-- ── RIGHT INFO PANEL ──────────────────────────────────────────── -->
  <aside class="info-panel" id="infoPanel">
    <asp:UpdatePanel ID="upInfoPanel" runat="server" UpdateMode="Conditional">
      <ContentTemplate>
        <asp:Literal ID="litInfoPanel" runat="server" />
      </ContentTemplate>
    </asp:UpdatePanel>
  </aside>
</div>

<!-- ── MODALS ──────────────────────────────────────────────────────── -->

<!-- New conversation / channel modal -->
<div class="modal fade" id="newConvoModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content" style="border-radius:var(--r-lg);border:none;overflow:hidden;">
      <div class="modal-header" style="border-bottom:1px solid var(--line);">
        <h5 class="font-display fw-bold mb-0" style="font-size:1.05rem;">Start something new</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <ul class="nav nav-pills gap-2 px-3 pt-3" id="newModalTabs">
        <li class="nav-item"><button class="nav-link active rounded-pill" data-target="tab-dm" style="font-family:var(--font-display);font-size:.8rem;font-weight:600;">Direct message</button></li>
        <li class="nav-item"><button class="nav-link rounded-pill" data-target="tab-ch" style="font-family:var(--font-display);font-size:.8rem;font-weight:600;">Create channel</button></li>
      </ul>
      <div class="modal-body pt-3">

        <!-- DM search -->
        <div id="tab-dm">
          <asp:UpdatePanel ID="upUserSearch" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
              <asp:TextBox ID="txtUserSearch" runat="server" CssClass="field-input mb-3"
                  placeholder="Search people…" AutoPostBack="true"
                  OnTextChanged="txtUserSearch_TextChanged" />
              <div style="max-height:280px;overflow-y:auto;" class="thin-scroll">
                <asp:Repeater ID="rptUserSearch" runat="server" OnItemCommand="rptUserSearch_ItemCommand">
                  <ItemTemplate>
                    <asp:Button ID="btnSelectUser" runat="server" CssClass="rail-item w-100 mb-1"
                        CommandName="StartDM" CommandArgument='<%# Eval("UserId") %>'
                        style="color:var(--ash-800);"
                        OnClientClick="bootstrap.Modal.getInstance(document.getElementById('newConvoModal')).hide();"
                        Text='<%# BuildUserSearchItem(Eval("DisplayName").ToString(), Eval("Username").ToString(), Eval("GetInitials()").ToString(), Eval("GetAvatarColor()").ToString(), (bool)Eval("IsOnline")) %>' />
                  </ItemTemplate>
                </asp:Repeater>
              </div>
            </ContentTemplate>
          </asp:UpdatePanel>
        </div>

        <!-- Create channel -->
        <div id="tab-ch" class="d-none">
          <label class="field-label" for="<%= txtNewChannelName.ClientID %>">Channel name</label>
          <asp:TextBox ID="txtNewChannelName" runat="server" CssClass="field-input mb-3"
              placeholder="e.g. release-planning" MaxLength="100" />
          <asp:RequiredFieldValidator ID="rfvChannelName" runat="server"
              ControlToValidate="txtNewChannelName"
              ErrorMessage="Enter a channel name."
              Display="Dynamic" CssClass="val-error"
              ValidationGroup="ChannelGroup" />

          <label class="field-label" for="<%= txtNewChannelTopic.ClientID %>">Description</label>
          <asp:TextBox ID="txtNewChannelTopic" runat="server" CssClass="field-input mb-3"
              placeholder="What's this channel for?" MaxLength="300" />

          <asp:Button ID="btnCreateChannel" runat="server" Text="Create channel"
              CssClass="btn-signal w-100" style="padding:.65rem;"
              OnClick="btnCreateChannel_Click" ValidationGroup="ChannelGroup"
              OnClientClick="bootstrap.Modal.getInstance(document.getElementById('newConvoModal'))?.hide();" />
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Settings modal -->
<div class="modal fade" id="settingsModal" tabindex="-1">
  <div class="modal-dialog modal-dialog-centered modal-lg">
    <div class="modal-content" style="border-radius:var(--r-lg);border:none;overflow:hidden;">
      <div class="d-flex" style="min-height:460px;">
        <div style="width:190px;flex-shrink:0;background:var(--paper-50);border-right:1px solid var(--line);padding:1rem 0;">
          <p class="px-3 mb-3" style="font-size:.68rem;font-weight:700;text-transform:uppercase;letter-spacing:.08em;color:var(--ash-400);font-family:var(--font-display);">Settings</p>
          <button class="settings-tab-btn active" data-tab="profile">Profile</button>
          <button class="settings-tab-btn" data-tab="notifications">Notifications</button>
          <button class="settings-tab-btn" data-tab="appearance">Appearance</button>
          <button class="settings-tab-btn" data-tab="privacy">Privacy</button>
        </div>
        <div class="flex-grow-1 p-4" style="overflow-y:auto;max-height:600px;">
          <button type="button" class="btn-close float-end" data-bs-dismiss="modal"></button>

          <!-- Profile panel -->
          <div class="settings-panel active" id="settings-profile">
            <h5 class="font-display fw-bold mb-3">Profile</h5>
            <asp:UpdatePanel ID="upSettings" runat="server" UpdateMode="Conditional">
              <ContentTemplate>
                <div class="mb-3">
                  <label class="field-label" for="<%= txtSetDisplayName.ClientID %>">Display name</label>
                  <asp:TextBox ID="txtSetDisplayName" runat="server" CssClass="field-input" MaxLength="100" />
                  <asp:RequiredFieldValidator ID="rfvSetDisplayName" runat="server"
                      ControlToValidate="txtSetDisplayName"
                      ErrorMessage="Display name is required."
                      Display="Dynamic" CssClass="val-error"
                      ValidationGroup="SettingsGroup" />
                </div>
                <div class="mb-3">
                  <label class="field-label" for="<%= txtSetStatus.ClientID %>">Status message</label>
                  <asp:TextBox ID="txtSetStatus" runat="server" CssClass="field-input" MaxLength="200"
                      placeholder="What are you working on?" />
                </div>
                <asp:Button ID="btnSaveProfile" runat="server" Text="Save changes"
                    CssClass="btn-signal" style="padding:.6rem 1.2rem;"
                    OnClick="btnSaveProfile_Click" ValidationGroup="SettingsGroup" />
                <asp:Panel ID="pnlSettingsSaved" runat="server" Visible="false"
                    style="color:var(--pulse-500);font-size:.82rem;margin-top:.5rem;">
                  ✅ Profile saved.
                </asp:Panel>
              </ContentTemplate>
            </asp:UpdatePanel>
          </div>

          <!-- Notifications panel -->
          <div class="settings-panel" id="settings-notifications">
            <h5 class="font-display fw-bold mb-3">Notifications</h5>
            <div class="d-flex align-items-center justify-content-between p-3 rounded-3 mb-2" style="background:var(--paper-50);border:1px solid var(--line);">
              <div><div style="font-weight:600;font-size:.85rem;">In-app toasts</div><div style="font-size:.78rem;color:var(--ash-500);">Show pop-up toasts for new messages</div></div>
              <button type="button" class="relay-switch on" id="swToasts" data-toggle="toasts"></button>
            </div>
            <div class="d-flex align-items-center justify-content-between p-3 rounded-3 mb-2" style="background:var(--paper-50);border:1px solid var(--line);">
              <div><div style="font-weight:600;font-size:.85rem;">Sound alerts</div><div style="font-size:.78rem;color:var(--ash-500);">Play a sound for new messages (browser permitting)</div></div>
              <button type="button" class="relay-switch" id="swSound" data-toggle="sound"></button>
            </div>
            <div class="d-flex align-items-center justify-content-between p-3 rounded-3 mb-2" style="background:var(--paper-50);border:1px solid var(--line);">
              <div><div style="font-weight:600;font-size:.85rem;">Mentions only</div><div style="font-size:.78rem;color:var(--ash-500);">Only notify when you're directly mentioned in a channel</div></div>
              <button type="button" class="relay-switch" id="swMentions" data-toggle="mentions"></button>
            </div>
          </div>

          <!-- Appearance panel -->
          <div class="settings-panel" id="settings-appearance">
            <h5 class="font-display fw-bold mb-3">Appearance</h5>
            <p class="field-label">Font size</p>
            <div class="d-flex gap-2 mb-4">
              <button type="button" class="btn-ghost flex-grow-1" data-size="0.85">Small</button>
              <button type="button" class="btn-signal flex-grow-1" data-size="1">Medium</button>
              <button type="button" class="btn-ghost flex-grow-1" data-size="1.18">Large</button>
            </div>
            <div class="d-flex align-items-center justify-content-between p-3 rounded-3" style="background:var(--paper-50);border:1px solid var(--line);">
              <div><div style="font-weight:600;font-size:.85rem;">Compact mode</div><div style="font-size:.78rem;color:var(--ash-500);">Show more messages by reducing spacing</div></div>
              <button type="button" class="relay-switch" id="compactSwitch" data-toggle="compact"></button>
            </div>
          </div>

          <!-- Privacy panel -->
          <div class="settings-panel" id="settings-privacy">
            <h5 class="font-display fw-bold mb-3">Privacy</h5>
            <div class="d-flex align-items-center justify-content-between p-3 rounded-3 mb-2" style="background:var(--paper-50);border:1px solid var(--line);">
              <div><div style="font-weight:600;font-size:.85rem;">Read receipts</div><div style="font-size:.78rem;color:var(--ash-500);">Let others know when you've read their messages</div></div>
              <button type="button" class="relay-switch on" id="swReadReceipts" data-toggle="receipts"></button>
            </div>
            <div class="d-flex align-items-center justify-content-between p-3 rounded-3 mb-2" style="background:var(--paper-50);border:1px solid var(--line);">
              <div><div style="font-weight:600;font-size:.85rem;">Show online status</div><div style="font-size:.78rem;color:var(--ash-500);">Let others see when you're active</div></div>
              <button type="button" class="relay-switch on" id="swOnlineStatus" data-toggle="onlinestatus"></button>
            </div>
            <div class="d-flex align-items-center justify-content-between p-3 rounded-3 mb-2" style="background:var(--paper-50);border:1px solid var(--line);">
              <div><div style="font-weight:600;font-size:.85rem;">Message previews in notifications</div><div style="font-size:.78rem;color:var(--ash-500);">Show message text in browser notifications</div></div>
              <button type="button" class="relay-switch on" id="swPreviews" data-toggle="previews"></button>
            </div>
          </div>

        </div>
      </div>
    </div>
  </div>
</div>

<!-- Thread offcanvas -->
<div class="offcanvas offcanvas-end" tabindex="-1" id="threadOffcanvas" style="width:340px;">
  <div class="offcanvas-header" style="border-bottom:1px solid var(--line);">
    <div>
      <h6 class="offcanvas-title font-display fw-bold" style="font-size:.95rem;">Thread</h6>
      <div class="font-mono" style="font-size:.7rem;color:var(--ash-400);" id="threadReplyCount"></div>
    </div>
    <button type="button" class="btn-close" data-bs-dismiss="offcanvas"></button>
  </div>
  <div class="offcanvas-body d-flex flex-column p-0">
    <div id="threadParent" style="padding:1rem;border-bottom:1px solid var(--line);background:var(--paper-50);flex-shrink:0;"></div>
    <div id="threadReplies" class="flex-grow-1 thin-scroll" style="overflow-y:auto;padding:.75rem 1rem;"></div>
    <div style="flex-shrink:0;padding:.75rem;">
      <div class="composer">
        <asp:UpdatePanel ID="upThreadComposer" runat="server" UpdateMode="Conditional">
          <ContentTemplate>
            <asp:TextBox ID="txtThreadReply" runat="server" TextMode="MultiLine" Rows="2"
                placeholder="Reply in thread…"
                style="width:100%;border:none;outline:none;resize:none;padding:.7rem .9rem;font-family:inherit;font-size:.88rem;color:var(--ash-800);background:transparent;" />
            <div class="composer-bottom">
              <span></span>
              <asp:Button ID="btnThreadSend" runat="server" Text="Reply"
                  CssClass="btn-signal" style="padding:.4rem .9rem;font-size:.8rem;"
                  OnClick="btnThreadSend_Click" ValidationGroup="ThreadGroup" />
            </div>
          </ContentTemplate>
        </asp:UpdatePanel>
      </div>
    </div>
  </div>
</div>

</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
/* ── Current user info from hidden fields ──────────────────────────── */
var CU = {
    id:       document.getElementById('<%= hfCurrentUserId.ClientID %>').value,
    name:     document.getElementById('<%= hfCurrentUserName.ClientID %>').value,
    initials: document.getElementById('<%= hfCurrentUserInitials.ClientID %>').value,
    color:    document.getElementById('<%= hfCurrentUserColor.ClientID %>').value,
    role:     document.getElementById('<%= hfCurrentUserRole.ClientID %>').value
};

/* ── State ──────────────────────────────────────────────────────────── */
var activeType = null, activeId = null;
var toastsEnabled = true, readReceiptsEnabled = true;
var mutedConvos = {};   // key "type_id" → true
var pinnedConvos = {};  // key "type_id" → true
var activeFilter = 'all';

/* ── Conversation selection ─────────────────────────────────────────── */
function selectConvo(type, id) {
    activeType = type; activeId = id;
    document.getElementById('composerWrap').style.display = 'block';
    renderConvoActions(type, id);
    showMessageSkeleton();

    // Post to server to load that conversation
    var form = document.getElementById('form1');
    var hfType = document.createElement('input');
    hfType.type = 'hidden'; hfType.name = 'hdnConvoType'; hfType.value = type;
    var hfId = document.createElement('input');
    hfId.type = 'hidden'; hfId.name = 'hdnConvoId'; hfId.value = id;
    form.appendChild(hfType); form.appendChild(hfId);
    __doPostBack('<%= btnLoadConvo.UniqueID %>', type + '_' + id);
}

/* ── Convo header action bar ─────────────────────────────────────────── */
function renderConvoActions(type, id) {
    var key = type + '_' + id;
    var isMuted = !!mutedConvos[key];
    var isPinned = !!pinnedConvos[key];
    var isChannel = type === 'channel';
    document.getElementById('convoActions').innerHTML =
        '<button class="icon-btn" id="searchInConvoBtn" title="Search in conversation">' +
          '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/></svg></button>' +
        '<button class="icon-btn" id="infoPanelBtn" title="Contact / channel info">' +
          '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg></button>' +
        '<div class="dropdown">' +
          '<button class="icon-btn" data-bs-toggle="dropdown" aria-label="More options">' +
            '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg></button>' +
          '<ul class="dropdown-menu dropdown-menu-end" style="font-size:.85rem;">' +
            '<li><button class="dropdown-item" id="muteConvoBtn">' + (isMuted ? 'Unmute conversation' : 'Mute conversation') + '</button></li>' +
            '<li><button class="dropdown-item" id="pinConvoBtn">' + (isPinned ? 'Unpin conversation' : 'Pin conversation') + '</button></li>' +
            '<li><button class="dropdown-item text-danger" id="leaveConvoBtn">' + (isChannel ? 'Leave channel' : 'Delete conversation') + '</button></li>' +
          '</ul>' +
        '</div>';

    document.getElementById('searchInConvoBtn').addEventListener('click', toggleInConvoSearch);
    document.getElementById('infoPanelBtn').addEventListener('click', toggleInfoPanel);
    document.getElementById('muteConvoBtn').addEventListener('click', function() {
        mutedConvos[key] = !mutedConvos[key];
        showToast(mutedConvos[key] ? 'Muted' : 'Unmuted',
            mutedConvos[key] ? 'You won\'t receive toasts for this conversation.' : 'Notifications restored.');
        applyMuteFlags();
        renderConvoActions(type, id);
    });
    document.getElementById('pinConvoBtn').addEventListener('click', function() {
        pinnedConvos[key] = !pinnedConvos[key];
        showToast(pinnedConvos[key] ? 'Pinned' : 'Unpinned',
            pinnedConvos[key] ? 'Moved to your pinned conversations.' : 'Removed from pinned.');
        applyPinned();
        renderConvoActions(type, id);
    });
    document.getElementById('leaveConvoBtn').addEventListener('click', function() {
        var verb = isChannel ? 'leave this channel' : 'delete this conversation';
        if (confirm('Are you sure you want to ' + verb + '? This cannot be undone.')) {
            showToast(isChannel ? 'Left channel' : 'Conversation deleted', 'Removed from your list.');
        }
    });
}

/* ── In-conversation search ─────────────────────────────────────────── */
function toggleInConvoSearch() {
    var bar = document.getElementById('inConvoSearchBar');
    bar.classList.toggle('d-none');
    if (!bar.classList.contains('d-none'))
        document.getElementById('inConvoSearchInput').focus();
    else
        document.getElementById('inConvoSearchInput').value = '';
}
document.getElementById('inConvoSearchInput').addEventListener('input', function() {
    var q = this.value.trim().toLowerCase();
    var visible = 0;
    document.querySelectorAll('#msgScroll .msg-row[data-msg-id]').forEach(function(row) {
        var bubble = row.querySelector('.bubble');
        if (!bubble) return;
        var show = (!q || bubble.textContent.toLowerCase().includes(q));
        row.style.display = show ? '' : 'none';
        if (show) visible++;
    });
    var empty = document.getElementById('searchEmptyState');
    if (empty) empty.classList.toggle('d-none', !(q && visible === 0));
});

/* ── Rail view: tab filter + search + empty state ───────────────────── */
function refreshRailView() {
    var q = (document.getElementById('railSearch').value || '').trim().toLowerCase();
    var visible = 0;
    document.querySelectorAll('#railList .rail-item').forEach(function(item) {
        var type = item.dataset.type || '';
        var unread = parseInt(item.dataset.unread || '0', 10);
        var nameEl = item.querySelector('.name');
        var name = nameEl ? nameEl.textContent.toLowerCase() : '';
        var passFilter = (activeFilter === 'all') ||
                         (activeFilter === 'direct'   && type === 'dm') ||
                         (activeFilter === 'channels' && type === 'channel') ||
                         (activeFilter === 'unread'   && unread > 0);
        var passSearch = (q === '' || name.indexOf(q) !== -1);
        var show = passFilter && passSearch;
        item.style.display = show ? '' : 'none';
        if (show) visible++;
    });
    var empty = document.getElementById('railEmptyState');
    if (empty) {
        if (visible === 0) {
            empty.classList.remove('d-none');
            empty.innerHTML = (activeFilter === 'unread')
                ? '<div class="d-flex flex-column align-items-center text-center py-5"><div style="width:40px;height:40px;border-radius:50%;background:rgba(255,255,255,.07);display:flex;align-items:center;justify-content:center;margin-bottom:.75rem;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#5B5B72" stroke-width="2"><path d="M20 6 9 17l-5-5"/></svg></div><p style="color:var(--ink-text-dimmer);font-size:.85rem;">All caught up!</p></div>'
                : '<div class="d-flex flex-column align-items-center text-center py-5"><p style="color:var(--ink-text-dimmer);font-size:.85rem;">No matches found.</p></div>';
        } else {
            empty.classList.add('d-none');
            empty.innerHTML = '';
        }
    }
}
document.querySelectorAll('.rail-tab').forEach(function(tab) {
    tab.addEventListener('click', function() {
        document.querySelectorAll('.rail-tab').forEach(function(t) { t.classList.remove('active'); });
        tab.classList.add('active');
        activeFilter = tab.dataset.filter;
        refreshRailView();
    });
});
document.getElementById('railSearch').addEventListener('input', refreshRailView);

/* ── Rail sections: collapse + hide-when-empty ──────────────────────── */
function toggleRailSection(name) {
    var sec = document.getElementById('railSection' + (name === 'dms' ? 'DMs' : 'Channels'));
    if (sec) sec.classList.toggle('collapsed');
}
function refreshRailSections() {
    ['railSectionDMs', 'railSectionChannels'].forEach(function(id) {
        var sec = document.getElementById(id);
        if (!sec) return;
        sec.style.display = sec.querySelector('.rail-item') ? '' : 'none';
    });
}

/* ── Pinned conversations (client-side) ─────────────────────────────── */
function applyPinned() {
    var list = document.getElementById('pinnedList');
    var section = document.getElementById('railSectionPinned');
    if (!list || !section) return;
    list.innerHTML = '';
    var count = 0;
    Object.keys(pinnedConvos).forEach(function(key) {
        if (!pinnedConvos[key]) return;
        var item = document.querySelector('#railList .rail-item[data-id="' + key + '"]');
        if (item) { list.appendChild(item); count++; }
    });
    section.style.display = count ? '' : 'none';
    applyMuteFlags();
}

/* ── Muted indicator on rail items ──────────────────────────────────── */
function muteIconHtml() {
    return '<span class="mute-flag" title="Muted"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M13.73 21a2 2 0 0 1-3.46 0"/><path d="M18.63 13A17.9 17.9 0 0 1 18 8"/><path d="M6.26 6.26A5.86 5.86 0 0 0 6 8c0 7-3 9-3 9h14"/><path d="M18 8a6 6 0 0 0-9.33-5"/><line x1="1" y1="1" x2="23" y2="23"/></svg></span>';
}
function applyMuteFlags() {
    document.querySelectorAll('#railList .rail-item').forEach(function(item) {
        var nameEl = item.querySelector('.name');
        if (!nameEl) return;
        var flag = nameEl.querySelector('.mute-flag');
        if (mutedConvos[item.dataset.id]) {
            if (!flag) nameEl.insertAdjacentHTML('beforeend', muteIconHtml());
        } else if (flag) {
            flag.remove();
        }
    });
}

/* ── Message loading skeleton ───────────────────────────────────────── */
function showMessageSkeleton() {
    var scroll = document.getElementById('msgScroll');
    if (!scroll) return;
    var rows = [true, false, true, false].map(function(own) {
        var w = 180 + Math.floor(Math.random() * 90);
        return '<div class="skel-row ' + (own ? 'own' : '') + '">' +
            (own ? '' : '<div class="skel-avatar skel-pulse"></div>') +
            '<div class="skel-bubble skel-pulse" style="width:' + w + 'px;"></div></div>';
    }).join('');
    scroll.innerHTML = rows;
}

/* ── Notification tray ──────────────────────────────────────────────── */
document.getElementById('notifBtn').addEventListener('click', function(e) {
    e.stopPropagation();
    document.getElementById('notifTray').classList.toggle('d-none');
});
document.addEventListener('click', function(e) {
    var tray = document.getElementById('notifTray');
    if (tray && !tray.classList.contains('d-none') &&
        !tray.contains(e.target) && e.target.id !== 'notifBtn') {
        tray.classList.add('d-none');
    }
});
document.getElementById('markAllReadBtn').addEventListener('click', function(e) {
    e.stopPropagation();
    document.querySelectorAll('#notifList .notif-row.unread').forEach(function(r) {
        r.classList.remove('unread');
    });
    document.getElementById('notifDot').style.display = 'none';
    showToast('Notifications', 'All marked as read.');
});
// Click a notification row to navigate to that conversation
document.getElementById('notifList').addEventListener('click', function(e) {
    var row = e.target.closest('.notif-row');
    if (!row) return;
    var ctype = row.dataset.convoType, cid = row.dataset.convoId;
    if (ctype && cid && cid !== '0') {
        document.getElementById('notifTray').classList.add('d-none');
        selectConvo(ctype, cid);
    }
    row.classList.remove('unread');
});

/* ── Info panel toggle ──────────────────────────────────────────────── */
function toggleInfoPanel() {
    document.getElementById('infoPanel').classList.toggle('show');
    var btn = document.getElementById('infoPanelBtn');
    if (btn) btn.classList.toggle('active');
}

/* ── Back button (mobile) ───────────────────────────────────────────── */
document.getElementById('backBtn').addEventListener('click', function() {
    document.getElementById('rail').classList.remove('hide-mobile');
    document.getElementById('convoCol').classList.remove('show-mobile');
});

/* ── Settings tabs ──────────────────────────────────────────────────── */
document.querySelectorAll('.settings-tab-btn').forEach(function(btn) {
    btn.addEventListener('click', function() {
        document.querySelectorAll('.settings-tab-btn').forEach(function(b) { b.classList.remove('active'); });
        btn.classList.add('active');
        document.querySelectorAll('.settings-panel').forEach(function(p) { p.classList.remove('active'); p.style.display = 'none'; });
        var panel = document.getElementById('settings-' + btn.dataset.tab);
        if (panel) { panel.classList.add('active'); panel.style.display = 'block'; }
    });
});

/* ── Settings toggles ───────────────────────────────────────────────── */
document.querySelectorAll('.relay-switch[data-toggle]').forEach(function(sw) {
    sw.addEventListener('click', function() {
        sw.classList.toggle('on');
        var on = sw.classList.contains('on');
        switch (sw.dataset.toggle) {
            case 'toasts':       toastsEnabled      = on; break;
            case 'receipts':     readReceiptsEnabled = on; document.body.classList.toggle('hide-receipts', !on); break;
            case 'compact':      document.body.classList.toggle('compact-mode', on); break;
            case 'onlinestatus': updateOwnPresenceUI(on); break;
        }
    });
});

/* ── New conversation modal tabs ────────────────────────────────────── */
document.querySelectorAll('#newModalTabs .nav-link').forEach(function(btn) {
    btn.addEventListener('click', function() {
        document.querySelectorAll('#newModalTabs .nav-link').forEach(function(b) { b.classList.remove('active'); });
        btn.classList.add('active');
        document.getElementById('tab-dm').classList.toggle('d-none', btn.dataset.target !== 'tab-dm');
        document.getElementById('tab-ch').classList.toggle('d-none', btn.dataset.target !== 'tab-ch');
    });
});

/* ── Appearance: font size ──────────────────────────────────────────── */
document.querySelectorAll('[data-size]').forEach(function(btn) {
    btn.addEventListener('click', function() {
        document.querySelectorAll('[data-size]').forEach(function(b) { b.className = 'btn-ghost flex-grow-1'; });
        btn.className = 'btn-signal flex-grow-1';
        document.documentElement.style.setProperty('--chat-font-scale', btn.dataset.size);
    });
});

/* ── Scroll messages to bottom after UpdatePanel refresh ────────────── */
function scrollToBottom() {
    var el = document.getElementById('msgScroll');
    if (el) el.scrollTop = el.scrollHeight;
}
function afterAjaxRefresh() {
    scrollToBottom();
    initComposerUI();
    wireHoverBars();
    refreshRailSections();
    applyPinned();
    applyMuteFlags();
    refreshRailView();
    updateEmptyState();
}

/* ── Empty conversation state ───────────────────────────────────────── */
function updateEmptyState() {
    var empty = document.getElementById('noMessagesState');
    var composer = document.getElementById('composerWrap');
    if (!empty) return;
    var hasConvo = composer && composer.style.display !== 'none';
    var count = document.querySelectorAll('#msgScroll .msg-row[data-msg-id]').length;
    empty.style.display = (hasConvo && count === 0) ? 'flex' : 'none';
}
if (typeof Sys !== 'undefined') {
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(afterAjaxRefresh);
}

/* ── Toast helper ───────────────────────────────────────────────────── */
function showToast(title, body, color) {
    if (!toastsEnabled) return;
    var t = document.createElement('div');
    t.className = 'relay-toast';
    t.innerHTML =
        '<div style="width:32px;height:32px;border-radius:9px;background:' + (color||'var(--signal-500)') +
        ';display:flex;align-items:center;justify-content:center;flex-shrink:0;">' +
        '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.3">' +
        '<path d="M18 8a6 6 0 1 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/>' +
        '<path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg></div>' +
        '<div style="min-width:0;">' +
        '<div style="font-family:var(--font-display);font-weight:700;font-size:.82rem;">' + escHtml(title) + '</div>' +
        '<div style="font-size:.78rem;color:#B9B9D6;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' + escHtml(body) + '</div></div>';
    document.body.appendChild(t);
    setTimeout(function() {
        t.style.opacity = '0'; t.style.transform = 'translateX(20px)'; t.style.transition = '.25s';
        setTimeout(function() { t.remove(); }, 260);
    }, 3800);
}
function escHtml(s) {
    var d = document.createElement('div'); d.textContent = s; return d.innerHTML;
}

/* ── Mobile: show convo column when a conversation is selected ───────── */
document.addEventListener('click', function(e) {
    var item = e.target.closest('.rail-item');
    if (item && window.innerWidth <= 900) {
        document.getElementById('rail').classList.add('hide-mobile');
        document.getElementById('convoCol').classList.add('show-mobile');
    }
});

/* ── Emoji picker ───────────────────────────────────────────────────── */
var EMOJI_GROUPS = {
    'Smileys':  ['😀','😂','😍','🤔','😊','😅','🥲','😭','🥳','😎','🤩','😬'],
    'Gestures': ['👍','👎','🙌','👏','🤝','💪','🫡','✌️','🤙','👋','🫶','🙏'],
    'Objects':  ['🔥','💯','✅','❌','⭐','💡','🚀','🎉','💬','📎','🔗','📊']
};
var activeEmojiCat = 'Smileys';
function renderEmojiPicker() {
    var cats = Object.keys(EMOJI_GROUPS);
    document.getElementById('emojiCatTabs').innerHTML = cats.map(function(c) {
        return '<button class="' + (c === activeEmojiCat ? 'active' : '') + '" data-cat="' + c + '">' + c + '</button>';
    }).join('');
    document.querySelectorAll('#emojiCatTabs button').forEach(function(b) {
        b.addEventListener('click', function() { activeEmojiCat = b.dataset.cat; renderEmojiPicker(); });
    });
    document.getElementById('emojiGrid').innerHTML = EMOJI_GROUPS[activeEmojiCat].map(function(e) {
        return '<button type="button">' + e + '</button>';
    }).join('');
    document.querySelectorAll('#emojiGrid button').forEach(function(b) {
        b.addEventListener('click', function() {
            var ta = document.querySelector('#upComposer textarea, #<%= txtMessage.ClientID %>');
            if (!ta) ta = document.getElementById('<%= txtMessage.ClientID %>');
            if (ta) { ta.value += b.textContent; ta.dispatchEvent(new Event('input')); ta.focus(); }
            document.getElementById('emojiPop').classList.add('d-none');
        });
    });
}
renderEmojiPicker();
document.addEventListener('click', function(e) {
    var pop = document.getElementById('emojiPop');
    if (pop && !pop.classList.contains('d-none') &&
        !pop.contains(e.target) && e.target.id !== 'emojiBtn') {
        pop.classList.add('d-none');
    }
});

/* ── Attach button (UI stub — file upload requires separate implementation) */
document.getElementById('attachBtn').addEventListener('click', function() {
    showToast('Attachments', 'File upload requires the attachment service (see SRS §FR-MSG-05).');
});

/* ── Message hover bars (wire after each UpdatePanel refresh) ──────── */
function wireHoverBars() {
    // React button on hover bar / reaction-add button
    document.querySelectorAll('.msg-hover-react').forEach(function(btn) {
        if (btn.dataset.wired === '1') return; btn.dataset.wired = '1';
        btn.addEventListener('click', function(e) {
            e.stopPropagation();
            var row = btn.closest('[data-msg-id]');
            if (!row) return;
            openMiniEmojiPicker(row.dataset.msgId, btn);
        });
    });
    // Reply in thread
    document.querySelectorAll('.msg-hover-reply').forEach(function(btn) {
        if (btn.dataset.wired === '1') return; btn.dataset.wired = '1';
        btn.addEventListener('click', function(e) {
            e.stopPropagation();
            var row = btn.closest('[data-msg-id]');
            if (row) openThread(row.dataset.msgId);
        });
    });
    // More (copy / delete)
    document.querySelectorAll('.msg-hover-more').forEach(function(btn) {
        if (btn.dataset.wired === '1') return; btn.dataset.wired = '1';
        btn.addEventListener('click', function(e) {
            e.stopPropagation();
            openMessageMoreMenu(btn);
        });
    });
}

/* ── Message "more" mini menu ───────────────────────────────────────── */
function openMessageMoreMenu(anchorBtn) {
    document.querySelectorAll('.mini-menu').forEach(function(m) { m.remove(); });
    var row = anchorBtn.closest('[data-msg-id]');
    if (!row) return;
    var msgId = row.dataset.msgId;
    var isOwn = anchorBtn.dataset.own === 'true';

    var menu = document.createElement('div');
    menu.className = 'mini-menu';
    menu.innerHTML =
        '<button type="button" data-act="copy">Copy text</button>' +
        (isOwn ? '<button type="button" data-act="delete" class="danger">Delete message</button>' : '');

    anchorBtn.parentNode.style.position = 'relative';
    anchorBtn.parentNode.appendChild(menu);

    menu.querySelector('[data-act="copy"]').addEventListener('click', function(e) {
        e.stopPropagation();
        var bubble = row.querySelector('.bubble');
        if (bubble && navigator.clipboard) navigator.clipboard.writeText(bubble.textContent.trim()).catch(function() {});
        showToast('Copied', 'Message text copied to clipboard.');
        menu.remove();
    });
    var del = menu.querySelector('[data-act="delete"]');
    if (del) del.addEventListener('click', function(e) {
        e.stopPropagation();
        menu.remove();
        if (confirm('Delete this message? This cannot be undone.')) deleteMessage(msgId);
    });

    setTimeout(function() {
        document.addEventListener('click', function h(e) {
            if (!menu.contains(e.target)) { menu.remove(); document.removeEventListener('click', h); }
        });
    }, 0);
}

/* ── Delete message via hidden postback ─────────────────────────────── */
function deleteMessage(msgId) {
    var form = document.getElementById('form1');
    var hf = document.createElement('input');
    hf.type = 'hidden'; hf.name = 'hdnDeleteMsgId'; hf.value = msgId;
    form.appendChild(hf);
    __doPostBack('<%= btnDeleteMsg.UniqueID %>', '');
}

/* ── Composer: formatting, auto-grow, Enter-to-send, voice ──────────── */
function applyFormat(type) {
    var ta = document.getElementById('<%= txtMessage.ClientID %>');
    if (!ta) return;
    var wrap = { bold: ['**', '**'], italic: ['*', '*'], code: ['`', '`'], link: ['[', '](https://)'] }[type];
    if (!wrap) return;
    var start = ta.selectionStart, end = ta.selectionEnd;
    var sel = ta.value.slice(start, end) || 'text';
    ta.value = ta.value.slice(0, start) + wrap[0] + sel + wrap[1] + ta.value.slice(end);
    ta.focus();
    var send = document.getElementById('<%= btnSend.ClientID %>');
    if (send) send.disabled = !ta.value.trim();
}
function initComposerUI() {
    var ta = document.getElementById('<%= txtMessage.ClientID %>');
    var send = document.getElementById('<%= btnSend.ClientID %>');
    if (ta && ta.dataset.composerWired !== '1') {
        ta.dataset.composerWired = '1';
        var sync = function() {
            ta.style.height = 'auto';
            ta.style.height = Math.min(ta.scrollHeight, 120) + 'px';
            if (send) send.disabled = !ta.value.trim();
        };
        ta.addEventListener('input', sync);
        ta.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                if (ta.value.trim()) { if (send) send.disabled = false; if (send) send.click(); }
            }
        });
        sync();
    }
    var eBtn = document.getElementById('emojiBtn');
    if (eBtn && eBtn.dataset.composerWired !== '1') {
        eBtn.dataset.composerWired = '1';
        eBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            var pop = document.getElementById('emojiPop');
            pop.classList.toggle('d-none');
            if (!pop.classList.contains('d-none')) renderEmojiPicker();
        });
    }
    var vBtn = document.getElementById('voiceBtn');
    if (vBtn && vBtn.dataset.composerWired !== '1') {
        vBtn.dataset.composerWired = '1';
        vBtn.addEventListener('click', function() {
            showToast('Voice message', 'Recording requires microphone access (planned enhancement).');
        });
    }
    // Format buttons live outside the UpdatePanel — wire once.
    document.querySelectorAll('[data-fmt]').forEach(function(b) {
        if (b.dataset.composerWired === '1') return; b.dataset.composerWired = '1';
        b.addEventListener('click', function() { applyFormat(b.dataset.fmt); });
    });
}

/* ── Own presence UI (rail footer) ──────────────────────────────────── */
function updateOwnPresenceUI(visible) {
    var dot = document.querySelector('.rail-foot .presence');
    var label = document.querySelector('.rail-foot .status-text');
    if (dot) dot.className = 'presence ' + (visible ? 'online' : 'offline');
    if (label) label.textContent = visible ? '● Active' : '● Appears offline';
}

/* ── Connection banner demo ─────────────────────────────────────────── */
function simulateConnectionBlip() {
    var banner = document.getElementById('connBanner');
    if (!banner) return;
    banner.classList.remove('success');
    banner.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M23 4v6h-6M1 20v-6h6"/><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/></svg> Connection lost — attempting to reconnect…';
    banner.classList.add('show');
    setTimeout(function() {
        banner.classList.add('success');
        banner.innerHTML = '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M20 6 9 17l-5-5"/></svg> Reconnected';
        setTimeout(function() { banner.classList.remove('show'); }, 1400);
    }, 2400);
}

/* ── Mini emoji picker (for reactions on hover) ─────────────────────── */
var QUICK_EMOJIS = ['👍','❤️','😂','🎉','👀','🙌'];
function openMiniEmojiPicker(msgId, anchorBtn) {
    document.querySelectorAll('.mini-emoji-pop').forEach(function(p) { p.remove(); });
    var pop = document.createElement('div');
    pop.className = 'mini-emoji-pop';
    pop.innerHTML = QUICK_EMOJIS.map(function(e) {
        return '<button type="button" data-emoji="' + e + '">' + e + '</button>';
    }).join('');
    anchorBtn.parentNode.style.position = 'relative';
    anchorBtn.parentNode.appendChild(pop);
    pop.querySelectorAll('button').forEach(function(b) {
        b.addEventListener('click', function(e) {
            e.stopPropagation();
            postReaction(msgId, b.dataset.emoji);
            pop.remove();
        });
    });
    setTimeout(function() {
        document.addEventListener('click', function h(e) {
            if (!pop.contains(e.target)) { pop.remove(); document.removeEventListener('click', h); }
        });
    }, 0);
}

/* ── Post reaction via hidden postback ─────────────────────────────── */
function postReaction(msgId, emoji) {
    var form = document.getElementById('form1');
    var hfMsg = document.createElement('input');
    hfMsg.type = 'hidden'; hfMsg.name = 'hdnReactMsgId'; hfMsg.value = msgId;
    var hfEmoji = document.createElement('input');
    hfEmoji.type = 'hidden'; hfEmoji.name = 'hdnReactEmoji'; hfEmoji.value = emoji;
    form.appendChild(hfMsg); form.appendChild(hfEmoji);
    __doPostBack('<%= btnReact.UniqueID %>', msgId + '_' + emoji);
}

/* ── Thread panel ───────────────────────────────────────────────────── */
function openThread(msgId) {
    var form = document.getElementById('form1');
    var hf = document.createElement('input');
    hf.type = 'hidden'; hf.name = 'hdnThreadMsgId'; hf.value = msgId;
    form.appendChild(hf);
    __doPostBack('<%= btnLoadThread.UniqueID %>', msgId);
    var oc = new bootstrap.Offcanvas(document.getElementById('threadOffcanvas'));
    oc.show();
}

/* ── Typing indicator helper (shown server-side via SignalR in production) */
function showTypingIndicator(name) {
    var row = document.getElementById('typingRow');
    if (row) {
        row.style.display = 'flex';
        var sub = document.getElementById('convoSubtitle');
        if (sub && name) sub.textContent = name + ' is typing…';
        var scroll = document.getElementById('msgScroll');
        if (scroll) scroll.scrollTop = scroll.scrollHeight;
    }
}
function hideTypingIndicator() {
    var row = document.getElementById('typingRow');
    if (row) row.style.display = 'none';
}

/* ── Initial wiring ─────────────────────────────────────────────────── */
scrollToBottom();
initComposerUI();
wireHoverBars();
refreshRailSections();
applyPinned();
applyMuteFlags();
refreshRailView();
setTimeout(simulateConnectionBlip, 7000);
updateEmptyState();
</script>
</body>
</html>
