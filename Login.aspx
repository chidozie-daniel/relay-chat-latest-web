<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="RelayChat.Web.Login" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Sign in — Relay Chat</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@500;600;700;800&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="<%=ResolveUrl("~/Content/css/site.css")%>" rel="stylesheet" />
</head>
<body>
<form id="form1" runat="server">
<asp:ScriptManager ID="ScriptManager1" runat="server" EnablePartialRendering="true" />

<div class="auth-shell">
    <!-- Left visual panel -->
    <div class="auth-visual d-none d-md-flex">
        <div class="grain"></div>
        <div style="position:relative;z-index:1;">
            <div class="d-flex align-items-center gap-2 mb-5">
                <div class="brand-mark"><svg viewBox="0 0 24 24" fill="none"><path d="M4 12c0-1.5 1-2.5 2.5-2.5S9 10.5 9 12s1 2.5 2.5 2.5S14 13.5 14 12s1-2.5 2.5-2.5S19 10.5 19 12" stroke="white" stroke-width="2" stroke-linecap="round"/></svg></div>
                <span class="brand-word fs-4 text-white">Relay Chat</span>
            </div>
            <h1 class="text-white fw-bold mb-3" style="font-size:2.4rem;max-width:460px;line-height:1.15;">Every message, relayed the moment it matters.</h1>
            <p style="color:#A7A7C7;max-width:420px;font-size:.95rem;">Private conversations and team channels, delivered in real time — built for teams who move fast together.</p>
        </div>
        <div class="relay-bubble-demo">
            <div class="bub">Deploy's cleared for Friday, CI is all green ✅</div>
            <div class="bub own">Perfect — I'll let the team know now.</div>
            <div class="d-flex align-items-center gap-2 mt-1" style="color:#7E7EA0;font-family:var(--font-mono);font-size:.72rem;">
                <span class="presence-ring online"><span class="presence online"></span></span> 3 teammates online now
            </div>
        </div>
    </div>

    <!-- Right form panel -->
    <div class="auth-form-col">
        <div class="auth-form-wrap">
            <div class="d-flex d-md-none align-items-center gap-2 mb-4">
                <div class="brand-mark"><svg viewBox="0 0 24 24" fill="none"><path d="M4 12c0-1.5 1-2.5 2.5-2.5S9 10.5 9 12s1 2.5 2.5 2.5S14 13.5 14 12s1-2.5 2.5-2.5S19 10.5 19 12" stroke="white" stroke-width="2" stroke-linecap="round"/></svg></div>
                <span class="brand-word fs-5">Relay Chat</span>
            </div>

            <h2 class="font-display fw-bold mb-1" style="font-size:1.6rem;color:var(--ash-800);">Welcome back</h2>
            <p class="mb-4" style="color:var(--ash-500);font-size:.9rem;">Sign in to keep the conversation going.</p>

            <!-- Server-side error banner -->
            <asp:Panel ID="pnlError" runat="server" Visible="false"
                CssClass="validation-summary-errors mb-3" role="alert">
                <asp:Literal ID="litError" runat="server" />
            </asp:Panel>

            <!-- Username / email -->
            <div class="mb-3">
                <label class="field-label" for="<%= txtIdentifier.ClientID %>">Username or email</label>
                <div class="input-wrap">
                    <span class="field-icon">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                    </span>
                    <asp:TextBox ID="txtIdentifier" runat="server" CssClass="field-input"
                        placeholder="you@relay.edu" autocomplete="username" />
                </div>
                <asp:RequiredFieldValidator ID="rfvIdentifier" runat="server"
                    ControlToValidate="txtIdentifier"
                    ErrorMessage="Enter your username or email to continue."
                    Display="Dynamic" CssClass="val-error"
                    ValidationGroup="LoginGroup" />
            </div>

            <!-- Password -->
            <div class="mb-2">
                <div class="d-flex justify-content-between align-items-baseline">
                    <label class="field-label" for="<%= txtPassword.ClientID %>">Password</label>
                    <a href="#forgotModal" id="forgotLink" style="font-size:.78rem;" data-bs-toggle="modal" data-bs-target="#forgotModal">Forgot password?</a>
                </div>
                <div class="input-wrap" id="pwWrap">
                    <span class="field-icon">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                    </span>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="field-input"
                        TextMode="Password" placeholder="••••••••" autocomplete="current-password" />
                    <button type="button" class="field-toggle" id="togglePw" aria-label="Show password">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8Z"/><circle cx="12" cy="12" r="3"/></svg>
                    </button>
                </div>
                <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                    ControlToValidate="txtPassword"
                    ErrorMessage="Enter your password to continue."
                    Display="Dynamic" CssClass="val-error"
                    ValidationGroup="LoginGroup" />
            </div>

            <!-- Remember me -->
            <div class="form-check mb-4 d-flex align-items-center gap-2">
                <asp:CheckBox ID="chkRemember" runat="server" Checked="true"
                    CssClass="form-check-input mt-0" style="border-color:var(--ash-300);" />
                <label class="form-check-label" for="<%= chkRemember.ClientID %>"
                    style="font-size:.85rem;color:var(--ash-600);">Remember me on this device</label>
            </div>

            <!-- Submit -->
            <asp:Button ID="btnLogin" runat="server" Text="Sign in"
                CssClass="btn-signal w-100 mb-3" style="padding:.75rem;"
                OnClick="btnLogin_Click" ValidationGroup="LoginGroup" />

            <div class="text-center" style="font-size:.85rem;color:var(--ash-500);">
                New to Relay Chat? <a href="Register.aspx">Create an account</a>
            </div>
            <p class="text-center mt-3" style="font-size:.72rem;color:var(--ash-400);">
                © 2026 Relay Chat · University Software Engineering Project
            </p>
        </div>
    </div>
</div>

<!-- Forgot password modal -->
<div class="modal fade" id="forgotModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:var(--r-lg);border:none;">
            <div class="modal-body p-4" id="forgotBody">
                <h5 class="font-display fw-bold mb-1">Reset your password</h5>
                <p style="font-size:.85rem;color:var(--ash-500);" class="mb-3">Enter the email on your account and we'll send a reset link.</p>
                <label class="field-label" for="<%= txtResetEmail.ClientID %>">Email address</label>
                <asp:TextBox ID="txtResetEmail" runat="server" CssClass="field-input mb-3"
                    placeholder="you@relay.edu" TextMode="Email" />
                <asp:RequiredFieldValidator ID="rfvResetEmail" runat="server"
                    ControlToValidate="txtResetEmail"
                    ErrorMessage="Enter your email address."
                    Display="Dynamic" CssClass="val-error"
                    ValidationGroup="ForgotGroup" />
                <asp:RegularExpressionValidator ID="revResetEmail" runat="server"
                    ControlToValidate="txtResetEmail"
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Enter a valid email address."
                    Display="Dynamic" CssClass="val-error"
                    ValidationGroup="ForgotGroup" />
                <asp:Button ID="btnSendReset" runat="server" Text="Send reset link"
                    CssClass="btn-signal w-100" style="padding:.65rem;"
                    OnClick="btnSendReset_Click" ValidationGroup="ForgotGroup" />
                <asp:Panel ID="pnlResetSuccess" runat="server" Visible="false" CssClass="text-center py-2 mt-3">
                    <p style="font-size:.85rem;color:var(--pulse-500);">
                        ✅ If an account matches that email, a reset link is on its way.
                    </p>
                </asp:Panel>
            </div>
        </div>
    </div>
</div>

</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
/* Show/hide password toggle */
document.getElementById('togglePw').addEventListener('click', function () {
    var pw = document.getElementById('<%= txtPassword.ClientID %>');
    pw.type = pw.type === 'password' ? 'text' : 'password';
});
</script>
</body>
</html>
