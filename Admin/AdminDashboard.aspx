<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="RelayChat.Web.Admin.AdminDashboard" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Admin Console — Relay Chat</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@500;600;700;800&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="<%=ResolveUrl("~/Content/css/site.css")%>" rel="stylesheet" />
</head>
<body>
<form id="form1" runat="server">
<asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true" />

<div class="admin-shell">

  <!-- ── ADMIN NAV ──────────────────────────────────────────────── -->
  <nav class="admin-nav" id="adminNav">
    <div class="d-flex align-items-center gap-2 px-3 py-3">
      <div class="brand-mark"><svg viewBox="0 0 24 24" fill="none"><path d="M4 12c0-1.5 1-2.5 2.5-2.5S9 10.5 9 12s1 2.5 2.5 2.5S14 13.5 14 12s1-2.5 2.5-2.5S19 10.5 19 12" stroke="white" stroke-width="2" stroke-linecap="round"/></svg></div>
      <div>
        <div class="brand-word text-white" style="font-size:.95rem;">Relay Chat</div>
        <div class="font-mono" style="font-size:.62rem;color:var(--ink-text-dimmer);">ADMIN CONSOLE</div>
      </div>
    </div>
    <div class="px-2 mt-2 flex-grow-1">
      <button class="admin-nav-link active" data-panel="dashboard">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="9"/><rect x="14" y="3" width="7" height="5"/><rect x="14" y="12" width="7" height="9"/><rect x="3" y="16" width="7" height="5"/></svg> Dashboard
      </button>
      <button class="admin-nav-link" data-panel="users">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/></svg> Users
      </button>
      <button class="admin-nav-link" data-panel="channels">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg> Channels
      </button>
    </div>
    <div class="p-2">
      <a href="~/Chat.aspx" class="admin-nav-link" runat="server">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 12H5M12 19l-7-7 7-7"/></svg> Back to Relay
      </a>
    </div>
  </nav>

  <!-- ── ADMIN MAIN ─────────────────────────────────────────────── -->
  <main class="admin-main">
    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h1 class="font-display fw-bold mb-0" style="font-size:1.5rem;" id="adminPanelTitle">Dashboard</h1>
        <p style="color:var(--ash-500);font-size:.85rem;margin:0;">Platform overview for Relay Chat</p>
      </div>
      <button class="icon-btn d-md-none" id="adminMenuBtn" style="border:1px solid var(--line);">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
      </button>
    </div>

    <!-- ── DASHBOARD PANEL ────────────────────────────────────── -->
    <div class="admin-panel active" id="panel-dashboard">
      <div class="row g-3 mb-4">
        <div class="col-6 col-lg-3">
          <div class="stat-card">
            <div class="stat-num"><asp:Literal ID="litStatUsers" runat="server" /></div>
            <div style="font-size:.8rem;color:var(--ash-500);">Registered users</div>
          </div>
        </div>
        <div class="col-6 col-lg-3">
          <div class="stat-card">
            <div class="stat-num"><asp:Literal ID="litStatChannels" runat="server" /></div>
            <div style="font-size:.8rem;color:var(--ash-500);">Active channels</div>
          </div>
        </div>
        <div class="col-6 col-lg-3">
          <div class="stat-card">
            <div class="stat-num"><asp:Literal ID="litStatOnline" runat="server" /></div>
            <div style="font-size:.8rem;color:var(--ash-500);">Online right now</div>
          </div>
        </div>
        <div class="col-6 col-lg-3">
          <div class="stat-card">
            <div class="stat-num"><asp:Literal ID="litStatSuspended" runat="server" /></div>
            <div style="font-size:.8rem;color:var(--ash-500);">Suspended accounts</div>
          </div>
        </div>
      </div>
      <div class="surface-card p-3">
        <h6 class="font-display fw-bold mb-3" style="font-size:.85rem;">All users at a glance</h6>
        <asp:Repeater ID="rptDashUsers" runat="server">
          <HeaderTemplate>
            <table class="data-table"><thead><tr><th>Name</th><th>Username</th><th>Role</th><th>Status</th><th>Joined</th></tr></thead><tbody>
          </HeaderTemplate>
          <ItemTemplate>
            <tr>
              <td><%# System.Web.HttpUtility.HtmlEncode(Eval("DisplayName").ToString()) %></td>
              <td class="font-mono" style="font-size:.78rem;">@<%# Eval("Username") %></td>
              <td><span class="badge-soft <%# Eval("Role").ToString()=="Administrator"?"badge-signal":"" %>"><%# Eval("Role") %></span></td>
              <td><span class="badge-soft <%# (bool)Eval("IsSuspended")?"badge-danger":"badge-pulse" %>"><%# (bool)Eval("IsSuspended")?"Suspended":"Active" %></span></td>
              <td style="font-size:.8rem;color:var(--ash-500);"><%# ((DateTime)Eval("CreatedAt")).ToString("MMM yyyy") %></td>
            </tr>
          </ItemTemplate>
          <FooterTemplate></tbody></table></FooterTemplate>
        </asp:Repeater>
      </div>
    </div>

    <!-- ── USERS PANEL ────────────────────────────────────────── -->
    <div class="admin-panel" id="panel-users">
      <asp:UpdatePanel ID="upUsers" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
          <div class="d-flex gap-2 mb-3">
            <div class="input-wrap flex-grow-1" style="max-width:320px;">
              <span class="field-icon"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/></svg></span>
              <asp:TextBox ID="txtUserSearch" runat="server" CssClass="field-input"
                  placeholder="Search users…" AutoPostBack="true"
                  OnTextChanged="txtUserSearch_TextChanged" />
            </div>
          </div>
          <div class="surface-card" style="overflow-x:auto;">
            <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
              <HeaderTemplate>
                <table class="data-table"><thead><tr><th>Name</th><th>Username</th><th>Email</th><th>Role</th><th>Status</th><th>Joined</th><th></th></tr></thead><tbody>
              </HeaderTemplate>
              <ItemTemplate>
                <tr>
                  <td><%# System.Web.HttpUtility.HtmlEncode(Eval("DisplayName").ToString()) %></td>
                  <td class="font-mono" style="font-size:.78rem;">@<%# Eval("Username") %></td>
                  <td style="color:var(--ash-500);"><%# Eval("Email") %></td>
                  <td><span class="badge-soft <%# Eval("Role").ToString()=="Administrator"?"badge-signal":"" %>"><%# Eval("Role") %></span></td>
                  <td><span class="badge-soft <%# (bool)Eval("IsSuspended")?"badge-danger":"badge-pulse" %>"><%# (bool)Eval("IsSuspended")?"Suspended":"Active" %></span></td>
                  <td style="font-size:.8rem;color:var(--ash-500);"><%# ((DateTime)Eval("CreatedAt")).ToString("MMM yyyy") %></td>
                  <td>
                    <asp:Button ID="btnToggleSuspend" runat="server" CssClass="btn-ghost"
                        style="padding:.3rem .7rem;font-size:.74rem;"
                        CommandName="ToggleSuspend"
                        CommandArgument='<%# Eval("UserId") %>'
                        Text='<%# (bool)Eval("IsSuspended") ? "Reactivate" : "Suspend" %>' />
                  </td>
                </tr>
              </ItemTemplate>
              <FooterTemplate></tbody></table></FooterTemplate>
            </asp:Repeater>
          </div>
        </ContentTemplate>
      </asp:UpdatePanel>
    </div>

    <!-- ── CHANNELS PANEL ─────────────────────────────────────── -->
    <div class="admin-panel" id="panel-channels">
      <div class="surface-card" style="overflow-x:auto;">
        <asp:Repeater ID="rptAdminChannels" runat="server">
          <HeaderTemplate>
            <table class="data-table"><thead><tr><th>Icon</th><th>Name</th><th>Topic</th><th>Owner</th><th>Created</th></tr></thead><tbody>
          </HeaderTemplate>
          <ItemTemplate>
            <tr>
              <td style="font-size:1.2rem;"><%# Eval("Icon") %></td>
              <td class="font-display fw-bold" style="font-size:.85rem;">#<%# Eval("Name") %></td>
              <td style="color:var(--ash-500);font-size:.82rem;"><%# System.Web.HttpUtility.HtmlEncode((Eval("Topic") ?? "").ToString()) %></td>
              <td style="font-size:.82rem;"><%# System.Web.HttpUtility.HtmlEncode(Eval("Owner.DisplayName").ToString()) %></td>
              <td style="font-size:.8rem;color:var(--ash-500);"><%# ((DateTime)Eval("CreatedAt")).ToString("MMM d, yyyy") %></td>
            </tr>
          </ItemTemplate>
          <FooterTemplate></tbody></table></FooterTemplate>
        </asp:Repeater>
      </div>
    </div>

  </main>
</div>

</form>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
/* Admin panel nav */
document.querySelectorAll('.admin-nav-link[data-panel]').forEach(function(btn) {
    btn.addEventListener('click', function() {
        document.querySelectorAll('.admin-nav-link[data-panel]').forEach(function(b) { b.classList.remove('active'); });
        btn.classList.add('active');
        document.querySelectorAll('.admin-panel').forEach(function(p) { p.classList.remove('active'); });
        document.getElementById('panel-' + btn.dataset.panel).classList.add('active');
        document.getElementById('adminPanelTitle').textContent =
            { dashboard: 'Dashboard', users: 'Users', channels: 'Channels' }[btn.dataset.panel];
        document.getElementById('adminNav').classList.remove('show');
    });
});
/* Mobile menu */
document.getElementById('adminMenuBtn').addEventListener('click', function() {
    document.getElementById('adminNav').classList.toggle('show');
});
</script>
</body>
</html>
