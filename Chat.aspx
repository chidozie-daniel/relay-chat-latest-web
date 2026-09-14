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
<asp:Button ID="btnLoadConvo" runat="server" style="display:none;"
    OnClick="btnLoadConvo_Click" CausesValidation="false" />

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
      </div>
    </div>

    <!-- Conversation list — rendered server-side, refreshed via UpdatePanel -->
    <asp:UpdatePanel ID="upRail" runat="server" UpdateMode="Conditional">
      <ContentTemplate>
        <div class="rail-list thin-scroll" id="railList">
          <asp:Repeater ID="rptDMs" runat="server" OnItemCommand="rptDMs_ItemCommand">
            <HeaderTemplate>
              <div class="rail-section-label">Direct Messages</div>
            </HeaderTemplate>
            <ItemTemplate>
              <button class="rail-item <%# (int)Eval("ConversationId") == SelectedConversationId && !IsChannel ? "active" : "" %>"
                data-id="dm_<%# Eval("ConversationId") %>"
                data-type="dm"
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
                  </div>
                </div>
              </button>
            </ItemTemplate>
          </asp:Repeater>

          <asp:Repeater ID="rptChannels" runat="server" OnItemCommand="rptChannels_ItemCommand">
            <HeaderTemplate>
              <div class="rail-section-label">Channels</div>
            </HeaderTemplate>
            <ItemTemplate>
              <button class="rail-item <%# (int)Eval("ChannelId") == SelectedChannelId && IsChannel ? "active" : "" %>"
                data-id="ch_<%# Eval("ChannelId") %>"
                data-type="channel"
                onclick="selectConvo('channel', <%# Eval("ChannelId") %>); return false;">
                <div class="channel-icon"><%# Eval("Icon") %></div>
                <div class="meta">
                  <div class="meta-top">
                    <span class="name">#<%# System.Web.HttpUtility.HtmlEncode(Eval("Name").ToString()) %></span>
                    <span class="time"><%# Eval("LastMessageTime") %></span>
                  </div>
                  <div class="preview-row">
                    <span class="preview"><%# System.Web.HttpUtility.HtmlEncode(Eval("LastMessagePreview").ToString()) %></span>
                  </div>
                </div>
              </button>
            </ItemTemplate>
          </asp:Repeater>
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
      <asp:Button ID="btnLogout" runat="server" CssClass="icon-btn-dark" title="Log out"
          OnClick="btnLogout_Click" Text="" style="background:none;border:none;"
          ToolTip="Log out">
      </asp:Button>
      <span style="pointer-events:none;position:absolute;right:48px;bottom:18px;">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--ink-text-dim)" stroke-width="2" style="pointer-events:none;"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="M16 17l5-5-5-5"/><path d="M21 12H9"/></svg>
      </span>
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
      <div id="convoAvatarWrap"></div>
      <div class="flex-grow-1" style="min-width:0;">
        <div class="title" id="convoTitle">Select a conversation</div>
        <div class="subtitle" id="convoSubtitle">Choose a DM or channel to get started</div>
      </div>
      <div id="convoActions" class="d-flex align-items-center gap-1"></div>
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
              <div class="msg-row <%# (bool)Eval("IsOwn") ? "own" : "" %>">
                <%# (bool)Eval("IsOwn") ? "" : "<div class=\"avatar\" style=\"width:30px;height:30px;background:" + Eval("SenderColor") + ";font-size:.7rem;flex-shrink:0;\">" + Eval("SenderInitials") + "</div>" %>
                <div class="msg-col">
                  <%# (bool)Eval("IsOwn") ? "" : "<div class=\"msg-sender\">" + System.Web.HttpUtility.HtmlEncode(Eval("SenderName").ToString()) + "</div>" %>
                  <div class="bubble <%# (bool)Eval("IsDeleted") ? "msg-deleted" : "" %>">
                    <%# System.Web.HttpUtility.HtmlEncode(Eval("DisplayBody").ToString()) %>
                  </div>
                  <div class="msg-foot">
                    <span class="t"><%# Eval("FormattedTime") %></span>
                  </div>
                </div>
              </div>
            </ItemTemplate>
          </asp:Repeater>
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
        </div>
        <asp:UpdatePanel ID="upComposer" runat="server" UpdateMode="Conditional">
          <ContentTemplate>
            <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine"
                placeholder="Message…" Rows="1"
                style="width:100%;border:none;outline:none;resize:none;padding:.6rem .95rem;font-size:.88rem;font-family:inherit;color:var(--ash-800);max-height:120px;display:block;background:transparent;" />
            <div class="composer-bottom">
              <div></div>
              <asp:Button ID="btnSend" runat="server" Text="Send"
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
          <button class="settings-tab-btn" data-tab="appearance">Appearance</button>
        </div>
        <div class="flex-grow-1 p-4" style="overflow-y:auto;">
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
              <button type="button" class="relay-switch" id="compactSwitch"></button>
            </div>
          </div>
        </div>
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

/* ── Conversation selection ─────────────────────────────────────────── */
var activeType = null, activeId = null;
function selectConvo(type, id) {
    activeType = type; activeId = id;
    document.getElementById('composerWrap').style.display = 'block';

    // Post to server to load that conversation
    var hfType = document.createElement('input');
    hfType.type = 'hidden'; hfType.name = 'hdnConvoType'; hfType.value = type;
    var hfId = document.createElement('input');
    hfId.type = 'hidden'; hfId.name = 'hdnConvoId'; hfId.value = id;
    var form = document.getElementById('form1');
    form.appendChild(hfType); form.appendChild(hfId);

    // Trigger the hidden ASP.NET button to load the conversation
    __doPostBack('<%= btnLoadConvo.UniqueID %>', type + '_' + id);
}

/* ── Rail filter tabs ───────────────────────────────────────────────── */
document.querySelectorAll('.rail-tab').forEach(function(tab) {
    tab.addEventListener('click', function() {
        document.querySelectorAll('.rail-tab').forEach(function(t) { t.classList.remove('active'); });
        tab.classList.add('active');
        var f = tab.dataset.filter;
        var dmSection  = document.querySelector('.rail-list');
        /* Simple client-side filter using data-type attributes */
        document.querySelectorAll('.rail-item').forEach(function(item) {
            var type = item.dataset.type || '';
            if (f === 'all') { item.style.display = ''; }
            else if (f === 'direct')   { item.style.display = type === 'dm'      ? '' : 'none'; }
            else if (f === 'channels') { item.style.display = type === 'channel' ? '' : 'none'; }
        });
    });
});

/* ── Rail search ────────────────────────────────────────────────────── */
document.getElementById('railSearch').addEventListener('input', function() {
    var q = this.value.trim().toLowerCase();
    document.querySelectorAll('.rail-item').forEach(function(item) {
        var name = item.querySelector('.name');
        if (!name) return;
        item.style.display = q === '' || name.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
});

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
        document.querySelectorAll('.settings-panel').forEach(function(p) { p.classList.remove('active'); });
        document.getElementById('settings-' + btn.dataset.tab).classList.add('active');
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

/* ── Compact mode switch ────────────────────────────────────────────── */
document.getElementById('compactSwitch').addEventListener('click', function() {
    this.classList.toggle('on');
    document.body.classList.toggle('compact-mode', this.classList.contains('on'));
});

/* ── Scroll messages to bottom after UpdatePanel refresh ────────────── */
function scrollToBottom() {
    var el = document.getElementById('msgScroll');
    if (el) el.scrollTop = el.scrollHeight;
}
if (typeof Sys !== 'undefined') {
    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function() {
        scrollToBottom();
    });
}
scrollToBottom();

/* ── Toast helper ───────────────────────────────────────────────────── */
function showToast(title, body, color) {
    var t = document.createElement('div');
    t.className = 'relay-toast';
    t.innerHTML = '<div style="width:32px;height:32px;border-radius:9px;background:' + (color||'var(--signal-500)') + ';display:flex;align-items:center;justify-content:center;flex-shrink:0;"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.3"><path d="M18 8a6 6 0 1 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg></div>'
        + '<div style="min-width:0;"><div style="font-family:var(--font-display);font-weight:700;font-size:.82rem;">' + title + '</div>'
        + '<div style="font-size:.78rem;color:#B9B9D6;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">' + body + '</div></div>';
    document.body.appendChild(t);
    setTimeout(function() { t.style.opacity='0'; t.style.transform='translateX(20px)'; t.style.transition='.25s'; setTimeout(function(){t.remove();},260); }, 3800);
}

/* ── Mobile: show convo column when a conversation is selected ───────── */
document.addEventListener('click', function(e) {
    var item = e.target.closest('.rail-item');
    if (item && window.innerWidth <= 900) {
        document.getElementById('rail').classList.add('hide-mobile');
        document.getElementById('convoCol').classList.add('show-mobile');
    }
});

/* ── Info panel toggle ──────────────────────────────────────────────── */
function toggleInfoPanel() {
    document.getElementById('infoPanel').classList.toggle('show');
    var btn = document.getElementById('infoPanelBtn');
    if (btn) btn.classList.toggle('active');
}
</script>
</body>
</html>
