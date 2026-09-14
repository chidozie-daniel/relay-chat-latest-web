<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="RelayChat.Web.Register" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Create account — Relay Chat</title>
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
            <h1 class="text-white fw-bold mb-3" style="font-size:2.2rem;max-width:440px;line-height:1.18;">Join your team on Relay in under a minute.</h1>
            <p style="color:#A7A7C7;max-width:400px;font-size:.95rem;">One account, every conversation — direct messages and channels, always in sync.</p>
            <ul class="list-unstyled mt-4" style="color:#C6C6E0;font-size:.85rem;">
                <li class="d-flex align-items-center gap-2 mb-2"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2AD9C9" stroke-width="2.5"><path d="M20 6 9 17l-5-5"/></svg> Real-time delivery, no refresh needed</li>
                <li class="d-flex align-items-center gap-2 mb-2"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2AD9C9" stroke-width="2.5"><path d="M20 6 9 17l-5-5"/></svg> Private chats and group channels</li>
                <li class="d-flex align-items-center gap-2"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#2AD9C9" stroke-width="2.5"><path d="M20 6 9 17l-5-5"/></svg> Full conversation history, always searchable</li>
            </ul>
        </div>
        <div style="position:relative;z-index:1;color:#7E7EA0;font-family:var(--font-mono);font-size:.72rem;">© 2026 Relay Chat · University Software Engineering Project</div>
    </div>

    <!-- Right form panel -->
    <div class="auth-form-col">
        <div class="auth-form-wrap">
            <div class="d-flex d-md-none align-items-center gap-2 mb-4">
                <div class="brand-mark"><svg viewBox="0 0 24 24" fill="none"><path d="M4 12c0-1.5 1-2.5 2.5-2.5S9 10.5 9 12s1 2.5 2.5 2.5S14 13.5 14 12s1-2.5 2.5-2.5S19 10.5 19 12" stroke="white" stroke-width="2" stroke-linecap="round"/></svg></div>
                <span class="brand-word fs-5">Relay Chat</span>
            </div>

            <h2 class="font-display fw-bold mb-1" style="font-size:1.6rem;color:var(--ash-800);">Create your account</h2>
            <p class="mb-4" style="color:var(--ash-500);font-size:.9rem;">It only takes a minute to get started.</p>

            <!-- Server error banner -->
            <asp:Panel ID="pnlError" runat="server" Visible="false"
                CssClass="validation-summary-errors mb-3" role="alert">
                <asp:Literal ID="litError" runat="server" />
            </asp:Panel>

            <!-- Display name -->
            <div class="mb-3">
                <label class="field-label" for="<%= txtDisplayName.ClientID %>">Display name</label>
                <asp:TextBox ID="txtDisplayName" runat="server" CssClass="field-input" placeholder="Jordan Reyes" MaxLength="100" />
                <asp:RequiredFieldValidator ID="rfvDisplayName" runat="server"
                    ControlToValidate="txtDisplayName"
                    ErrorMessage="Enter the name others will see."
                    Display="Dynamic" CssClass="val-error"
                    ValidationGroup="RegGroup" />
                <asp:RegularExpressionValidator ID="revDisplayName" runat="server"
                    ControlToValidate="txtDisplayName"
                    ValidationExpression="^.{2,100}$"
                    ErrorMessage="Display name must be at least 2 characters."
                    Display="Dynamic" CssClass="val-error"
                    ValidationGroup="RegGroup" />
            </div>

            <!-- Username -->
            <div class="mb-3">
                <label class="field-label" for="<%= txtUsername.ClientID %>">Username</label>
                <asp:TextBox ID="txtUsername" runat="server" CssClass="field-input" placeholder="jordan.reyes" MaxLength="50" />
                <asp:RequiredFieldValidator ID="rfvUsername" runat="server"
                    ControlToValidate="txtUsername"
                    ErrorMessage="Choose a username."
                    Display="Dynamic" CssClass="val-error"
                    ValidationGroup="RegGroup" />
                <asp:RegularExpressionValidator ID="revUsername" runat="server"
                    ControlToValidate="txtUsername"
                    ValidationExpression="^[a-zA-Z0-9._\-]{3,50}$"
                    ErrorMessage="Username must be 3–50 characters: letters, numbers, dots, hyphens, or underscores."
                    Display="Dynamic" CssClass="val-error"
                    ValidationGroup="RegGroup" />
                <asp:CustomValidator ID="cvUsername" runat="server"
                    ControlToValidate="txtUsername"
                    ErrorMessage="That username is already taken."
                    Display="Dynamic" CssClass="val-error"
                    ValidationGroup="RegGroup"
                    OnServerValidate="cvUsername_ServerValidate" />
            </div>

            <!-- Email -->
            <div class="mb-3">
                <label class="field-label" for="<%= txtEmail.ClientID %>">Email address</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="field-input" placeholder="jordan@relay.edu" TextMode="Email" MaxLength="256" />
                <asp:RequiredFieldValidator ID="rfvEmail" runat="server"
                    ControlToValidate="txtEmail"
                    ErrorMessage="Enter your email address."
                    Display="Dynamic" CssClass="val-error"
                    ValidationGroup="RegGroup" />
                <asp:RegularExpressionValidator ID="revEmail" runat="server"
                    ControlToValidate="txtEmail"
                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$"
                    ErrorMessage="Enter a valid email address."
                    Display="Dynamic" CssClass="val-error"
                    ValidationGroup="RegGroup" />
                <asp:CustomValidator ID="cvEmail" runat="server"
                    ControlToValidate="txtEmail"
                    ErrorMessage="An account with that email already exists."
                    Display="Dynamic" CssClass="val-error"
                    ValidationGroup="RegGroup"
                    OnServerValidate="cvEmail_ServerValidate" />
            </div>

            <!-- Password -->
            <div class="mb-2">
                <label class="field-label" for="<%= txtPassword.ClientID %>">Password</label>
                <div class="input-wrap">
                    <span class="field-icon"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></span>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="field-input"
                        TextMode="Password" placeholder="At least 8 characters" MaxLength="128" />
                </div>
                <div class="pw-meter"><i id="pwBar1"></i><i id="pwBar2"></i><i id="pwBar3"></i></div>
                <div class="field-hint" id="pwHint">Use at least 8 characters with a letter and a number.</div>
                <asp:RequiredFieldValidator ID="rfvPassword" runat="server"
                    ControlToValidate="txtPassword"
                    ErrorMessage="Enter a password."
                    Display="Dynamic" CssClass="val-error"
                    ValidationGroup="RegGroup" />
                <asp:RegularExpressionValidator ID="revPassword" runat="server"
                    ControlToValidate="txtPassword"
                    ValidationExpression="^(?=.*[A-Za-z])(?=.*\d).{8,}$"
                    ErrorMessage="Password must be at least 8 characters, with at least one letter and one number."
                    Display="Dynamic" CssClass="val-error"
                    ValidationGroup="RegGroup" />
            </div>

            <!-- Confirm password -->
            <div class="mb-3">
                <label class="field-label" for="<%= txtConfirmPassword.ClientID %>">Confirm password</label>
                <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="field-input"
                    TextMode="Password" placeholder="Re-enter password" MaxLength="128" />
                <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server"
                    ControlToValidate="txtConfirmPassword"
                    ErrorMessage="Please confirm your password."
                    Display="Dynamic" CssClass="val-error"
                    ValidationGroup="RegGroup" />
                <asp:CompareValidator ID="cvPasswords" runat="server"
                    ControlToValidate="txtConfirmPassword"
                    ControlToCompare="txtPassword"
                    ErrorMessage="Passwords don't match."
                    Display="Dynamic" CssClass="val-error"
                    ValidationGroup="RegGroup" />
            </div>

            <!-- Terms -->
            <div class="form-check mb-2 d-flex align-items-start gap-2">
                <asp:CheckBox ID="chkTerms" runat="server"
                    CssClass="form-check-input mt-1" style="border-color:var(--ash-300);" />
                <label class="form-check-label" for="<%= chkTerms.ClientID %>"
                    style="font-size:.82rem;color:var(--ash-600);">
                    I agree to the Relay Chat <a href="#">Terms of Service</a> and <a href="#">Privacy Policy</a>.
                </label>
            </div>
            <asp:CustomValidator ID="cvTerms" runat="server"
                ErrorMessage="Please accept the terms to continue."
                Display="Dynamic" CssClass="val-error mb-3"
                ValidationGroup="RegGroup"
                OnServerValidate="cvTerms_ServerValidate" />

            <!-- Submit -->
            <asp:Button ID="btnRegister" runat="server" Text="Create account"
                CssClass="btn-signal w-100 mt-2" style="padding:.75rem;"
                OnClick="btnRegister_Click" ValidationGroup="RegGroup" />

            <div class="text-center mt-3" style="font-size:.85rem;color:var(--ash-500);">
                Already have an account? <a href="Login.aspx">Sign in</a>
            </div>
        </div>
    </div>
</div>

</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
/* Password strength meter — purely visual, no validation logic */
document.getElementById('<%= txtPassword.ClientID %>').addEventListener('input', function () {
    var v = this.value, score = 0;
    if (v.length >= 8) score++;
    if (/[0-9]/.test(v) && /[a-zA-Z]/.test(v)) score++;
    if (v.length >= 12 && /[^a-zA-Z0-9]/.test(v)) score++;
    var bars   = [document.getElementById('pwBar1'), document.getElementById('pwBar2'), document.getElementById('pwBar3')];
    var colors = ['var(--danger)', 'var(--warn)', 'var(--pulse-500)'];
    bars.forEach(function (b, i) { b.style.background = i < score ? colors[score - 1] : 'var(--paper-100)'; });
    var hint = document.getElementById('pwHint');
    hint.textContent = v.length === 0 ? 'Use at least 8 characters with a letter and a number.'
        : score <= 1 ? 'Weak — add numbers, letters, and more length.'
        : score === 2 ? 'Good — this password is solid.'
        : 'Strong password.';
});
</script>
</body>
</html>
