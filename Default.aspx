<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="RelayChat.Web.Default" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Relay Chat — Every message, relayed the moment it matters</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@500;600;700;800&family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="<%=ResolveUrl("~/Content/css/site.css")%>" rel="stylesheet" />
</head>
<body>

<!-- NAV -->
<nav class="lp-nav" id="lpNav">
    <div class="container-lp lp-nav-inner">
        <a href="Default.aspx" class="d-flex align-items-center gap-2" style="text-decoration:none;">
            <div class="brand-mark"><svg viewBox="0 0 24 24" fill="none"><path d="M4 12c0-1.5 1-2.5 2.5-2.5S9 10.5 9 12s1 2.5 2.5 2.5S14 13.5 14 12s1-2.5 2.5-2.5S19 10.5 19 12" stroke="white" stroke-width="2" stroke-linecap="round"/></svg></div>
            <span class="brand-word fs-5">Relay Chat</span>
        </a>
        <div class="lp-nav-links" id="navLinks">
            <a href="#features" data-nav="features">Features</a>
            <a href="#showcase" data-nav="showcase">Showcase</a>
            <a href="#how" data-nav="how">How it works</a>
            <a href="#testimonials" data-nav="testimonials">Team</a>
            <a href="#faq" data-nav="faq">FAQ</a>
        </div>
        <div class="lp-nav-actions">
            <a href="Login.aspx" class="btn-ghost d-none d-md-inline-flex">Sign in</a>
            <a href="Register.aspx" class="btn-signal d-none d-md-inline-flex">Get started</a>
            <button class="lp-burger" id="lpBurger" aria-label="Open menu"><span></span></button>
        </div>
    </div>
</nav>

<div class="lp-mobile-menu" id="mobileMenu">
    <a href="#features" class="nav-item">Features</a>
    <a href="#showcase" class="nav-item">Showcase</a>
    <a href="#how" class="nav-item">How it works</a>
    <a href="#testimonials" class="nav-item">Team</a>
    <a href="#faq" class="nav-item">FAQ</a>
    <div class="mob-cta">
        <a href="Login.aspx" class="btn-ghost w-100">Sign in</a>
        <a href="Register.aspx" class="btn-signal w-100">Get started free</a>
    </div>
</div>

<!-- HERO -->
<header class="lp-hero" id="top">
    <div class="lp-hero-bg-grain"></div>
    <div class="lp-hero-blob b1"></div>
    <div class="lp-hero-blob b2"></div>
    <div class="container-lp lp-hero-grid">
        <div>
            <span class="eyebrow-badge"><span class="dot"></span> University Software Engineering Project · ASP.NET Web Forms + SQL Server</span>
            <h1 class="lp-h1">Every message,<br><span class="accent">relayed</span> the moment it matters.</h1>
            <p class="lp-hero-sub">Relay Chat is a real-time web chat platform built for teams — private conversations, group channels, live presence, and full history, delivered the instant it happens.</p>
            <div class="lp-hero-cta">
                <a href="Register.aspx" class="btn-signal btn-lg-lp">Get started free
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M13 5l7 7-7 7"/></svg>
                </a>
                <a href="#showcase" class="btn-ghost btn-lg-lp">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z"/></svg>
                    See it in action
                </a>
            </div>
            <div class="lp-trust-row">
                <div class="avatar-stack">
                    <div class="av" style="background:#5B5FEF;">NB</div>
                    <div class="av" style="background:#17BFB0;">YT</div>
                    <div class="av" style="background:#E4572E;">GA</div>
                    <div class="av" style="background:#F0A63E;">PM</div>
                </div>
                <p>Built and used daily by <strong>Noah, Yuki, Grace, Priya</strong> &amp; the rest of the team</p>
            </div>
        </div>
        <div class="lp-hero-visual reveal">
            <div class="floating-card fc1">
                <div class="fc-icon" style="background:var(--pulse-100);"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--pulse-500)" stroke-width="2.4"><path d="M20 6 9 17l-5-5"/></svg></div>
                <div><div class="fc-title">Delivered</div><div class="fc-sub">&lt; 1 second</div></div>
            </div>
            <div class="mock-frame">
                <div class="mock-chrome"><i></i><i></i><i></i><span class="url">relay.chat/app</span></div>
                <div class="mock-body">
                    <div class="mock-msg-row"><div class="mock-avatar" style="background:#5B5FEF;">NB</div><div class="mock-bubble">Pushed the SignalR hub changes — reconnects are solid now.</div></div>
                    <div class="mock-msg-row own"><div class="mock-bubble">Reviewing against the SRS real-time requirements now.</div></div>
                    <div class="mock-msg-row"><div class="mock-avatar" style="background:#5B5FEF;">NB</div><div class="mock-typing"><i></i><i></i><i></i></div></div>
                </div>
            </div>
            <div class="floating-card fc2">
                <div class="fc-icon" style="background:var(--signal-100);"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--signal-500)" stroke-width="2.4"><path d="M18 8a6 6 0 1 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg></div>
                <div><div class="fc-title">3 new replies</div><div class="fc-sub">#relay-core-team</div></div>
            </div>
        </div>
    </div>
</header>

<!-- STATS -->
<section class="lp-stats">
    <div class="container-lp">
        <div class="row g-4">
            <div class="col-6 col-lg-3 lp-stat reveal"><div class="num"><span data-count="24">0</span></div><div class="lbl">Functional requirements mapped from the SRS</div></div>
            <div class="col-6 col-lg-3 lp-stat reveal"><div class="num"><span data-count="6">0</span></div><div class="lbl">Core feature areas: DMs, channels, presence &amp; more</div></div>
            <div class="col-6 col-lg-3 lp-stat reveal"><div class="num"><span data-count="2">0</span></div><div class="lbl">Client surfaces — workspace and admin console</div></div>
            <div class="col-6 col-lg-3 lp-stat reveal"><div class="num"><span data-count="1">0</span><span class="suffix">s</span></div><div class="lbl">Target delivery time for a sent message</div></div>
        </div>
    </div>
</section>

<!-- FEATURES -->
<section id="features" class="lp-section">
    <div class="container-lp">
        <div class="section-head reveal">
            <span class="section-eyebrow">Features</span>
            <h2>Everything a modern team chat needs</h2>
            <p>Relay Chat covers the full communication loop — from a quick direct message to a whole team channel — without the clutter.</p>
        </div>
        <div class="row g-4">
            <div class="col-md-6 col-lg-4 reveal">
                <div class="feature-card">
                    <div class="feature-icon" style="background:var(--signal-100);"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--signal-500)" stroke-width="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg></div>
                    <h3>Real-time messaging</h3>
                    <p>Messages arrive the instant they're sent — no refresh needed. Built on SQL Server with live push via AJAX polling.</p>
                    <span class="req-tag">FR-RT-02</span>
                </div>
            </div>
            <div class="col-md-6 col-lg-4 reveal">
                <div class="feature-card">
                    <div class="feature-icon" style="background:var(--pulse-100);"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--pulse-500)" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/></svg></div>
                    <h3>Group channels</h3>
                    <p>Spin up a channel, invite your team, and manage membership with owner controls — separate from your DMs.</p>
                    <span class="req-tag">FR-GRP-01</span>
                </div>
            </div>
            <div class="col-md-6 col-lg-4 reveal">
                <div class="feature-card">
                    <div class="feature-icon" style="background:#FDECEF;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--danger)" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M8 14s1.5 2 4 2 4-2 4-2"/><line x1="9" y1="9" x2="9.01" y2="9"/><line x1="15" y1="9" x2="15.01" y2="9"/></svg></div>
                    <h3>Presence indicators</h3>
                    <p>See who's online, away, or offline at a glance — presence updates automatically as users sign in and out.</p>
                    <span class="req-tag">FR-PRES-01</span>
                </div>
            </div>
            <div class="col-md-6 col-lg-4 reveal">
                <div class="feature-card">
                    <div class="feature-icon" style="background:#FFF4E5;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--warn)" stroke-width="2"><circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/></svg></div>
                    <h3>Conversation search</h3>
                    <p>Find a person, a channel, or a specific message from a long conversation in a couple of keystrokes.</p>
                    <span class="req-tag">FR-SEARCH-01</span>
                </div>
            </div>
            <div class="col-md-6 col-lg-4 reveal">
                <div class="feature-card">
                    <div class="feature-icon" style="background:var(--signal-100);"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--signal-500)" stroke-width="2"><path d="M18 8a6 6 0 1 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg></div>
                    <h3>Smart notifications</h3>
                    <p>Unread badges and in-app toasts that stay out of your way until you need them.</p>
                    <span class="req-tag">FR-NOTIF-01</span>
                </div>
            </div>
            <div class="col-md-6 col-lg-4 reveal">
                <div class="feature-card">
                    <div class="feature-icon" style="background:var(--pulse-100);"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="var(--pulse-500)" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10Z"/></svg></div>
                    <h3>Admin console</h3>
                    <p>Full administrator dashboard — user management, suspension, role promotion, and activity logs.</p>
                    <span class="req-tag">FR-ADMIN-01</span>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- SHOWCASE -->
<section id="showcase" class="lp-section" style="background:var(--paper-0); border-top:1px solid var(--line); border-bottom:1px solid var(--line);">
    <div class="container-lp">
        <div class="section-head reveal">
            <span class="section-eyebrow">Showcase</span>
            <h2>See it in action</h2>
            <p>A quick look at three of Relay Chat's core surfaces — click through to explore each one.</p>
        </div>
        <div class="lp-showcase-tabs reveal">
            <button class="showcase-tab-btn active" data-tab="dm">Direct messages</button>
            <button class="showcase-tab-btn" data-tab="channel">Channels</button>
            <button class="showcase-tab-btn" data-tab="notif">Notifications</button>
        </div>
        <div class="showcase-frame reveal">
            <div class="mock-frame">
                <div class="mock-chrome"><i></i><i></i><i></i><span class="url">relay.chat/chat</span></div>
                <div class="showcase-panel active" data-panel="dm">
                    <div class="mock-body" style="padding:1.4rem;">
                        <div class="mock-msg-row"><div class="mock-avatar" style="background:#17BFB0;">YT</div><div class="mock-bubble">Ran the full regression suite against the auth flow this morning.</div></div>
                        <div class="mock-msg-row own"><div class="mock-bubble">How'd it look? Password reset especially.</div></div>
                        <div class="mock-msg-row"><div class="mock-avatar" style="background:#17BFB0;">YT</div><div class="mock-bubble">Green across the board, including reset ✅</div></div>
                        <div class="mock-msg-row own"><div class="mock-bubble">Perfect, appreciate the update.</div></div>
                    </div>
                </div>
                <div class="showcase-panel" data-panel="channel">
                    <div class="mock-body" style="padding:1.4rem;">
                        <div style="display:flex;align-items:center;gap:.5rem;margin-bottom:1rem;padding-bottom:.9rem;border-bottom:1px solid var(--line);">
                            <div style="width:32px;height:32px;border-radius:9px;background:var(--paper-100);display:flex;align-items:center;justify-content:center;font-size:1rem;">📡</div>
                            <div><div style="font-weight:700;font-size:.85rem;">#relay-core-team</div><div style="font-size:.72rem;color:var(--ash-500);">8 members</div></div>
                        </div>
                        <div class="mock-msg-row"><div class="mock-avatar" style="background:#5B5FEF;">AO</div><div class="mock-bubble">Sprint check-in: frontend prototype is basically done.</div></div>
                        <div class="mock-msg-row"><div class="mock-avatar" style="background:#17BFB0;">YT</div><div class="mock-bubble">QA can start writing test cases off the prototype states.</div></div>
                        <div class="mock-msg-row"><div class="mock-avatar" style="background:#5B5FEF;">NB</div><div class="mock-bubble">Hub reconnect logic is in</div></div>
                    </div>
                </div>
                <div class="showcase-panel" data-panel="notif">
                    <div class="mock-body" style="padding:1.4rem;">
                        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:1rem;">
                            <strong style="font-family:var(--font-display);font-size:.9rem;">Notifications</strong>
                            <span style="font-family:var(--font-mono);font-size:.68rem;background:var(--signal-500);color:#fff;border-radius:99px;padding:.1rem .55rem;">3</span>
                        </div>
                        <div style="display:flex;gap:.6rem;padding:.6rem 0;border-bottom:1px solid var(--line-soft);"><div class="mock-avatar" style="background:#5B5FEF;">NB</div><div><div style="font-size:.8rem;font-weight:600;">Noah Bennett</div><div style="font-size:.76rem;color:var(--ash-500);">Pushed the hub changes, can you pull?</div></div></div>
                        <div style="display:flex;gap:.6rem;padding:.6rem 0;border-bottom:1px solid var(--line-soft);"><div class="mock-avatar" style="background:#E4572E;">GA</div><div><div style="font-size:.8rem;font-weight:600;">Grace Adeyemi</div><div style="font-size:.76rem;color:var(--ash-500);">Nice progress on the SRS — a few notes attached.</div></div></div>
                        <div style="display:flex;gap:.6rem;padding:.6rem 0;"><div class="mock-avatar" style="background:#5B5FEF;">📡</div><div><div style="font-size:.8rem;font-weight:600;">#relay-core-team</div><div style="font-size:.76rem;color:var(--ash-500);">Noah: Hub reconnect logic is in</div></div></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- HOW IT WORKS -->
<section id="how" class="lp-section">
    <div class="container-lp">
        <div class="section-head reveal">
            <span class="section-eyebrow">How it works</span>
            <h2>From sign-up to your first channel in minutes</h2>
            <p>No lengthy onboarding — just create an account and start talking to your team.</p>
        </div>
        <div class="steps-row">
            <div class="step-card reveal"><div class="step-num">1</div><h4>Create your account</h4><p>Sign up with a username, email, and password — validated server-side, hashed securely, never stored in plain text.</p></div>
            <div class="step-card reveal"><div class="step-num">2</div><h4>Start a conversation</h4><p>Search for a teammate and send your first direct message — stored instantly in SQL Server.</p></div>
            <div class="step-card reveal"><div class="step-num">3</div><h4>Build a channel</h4><p>Create a channel, name it, and invite the people who need to be in the conversation.</p></div>
            <div class="step-card reveal"><div class="step-num">4</div><h4>Stay in sync</h4><p>Presence indicators and notifications keep everyone on the same page — automatically.</p></div>
        </div>
    </div>
</section>

<!-- TESTIMONIALS -->
<section id="testimonials" class="lp-section" style="background:var(--paper-0); border-top:1px solid var(--line); border-bottom:1px solid var(--line);">
    <div class="container-lp">
        <div class="section-head reveal">
            <span class="section-eyebrow">The team behind it</span>
            <h2>What the team says</h2>
            <p>Relay Chat is built and used by the same small team every day.</p>
        </div>
        <div class="testi-wrap reveal">
            <div class="testi-card active" data-slide="0">
                <p class="testi-quote">Wiring the data layer into the SRS's real-time requirements was straightforward once the frontend was already speaking the same language.</p>
                <div class="testi-person"><div class="testi-av" style="background:#5B5FEF;">NB</div><div><div class="testi-name">Noah Bennett</div><div class="testi-role">Backend Engineer</div></div></div>
            </div>
            <div class="testi-card" data-slide="1">
                <p class="testi-quote">I could write test cases straight off the prototype's states — empty, loading, error — it was all already there.</p>
                <div class="testi-person"><div class="testi-av" style="background:#17BFB0;">YT</div><div><div class="testi-name">Yuki Tanaka</div><div class="testi-role">QA Engineer</div></div></div>
            </div>
            <div class="testi-card" data-slide="2">
                <p class="testi-quote">This is the kind of requirements-to-design traceability I want to see in a capstone project.</p>
                <div class="testi-person"><div class="testi-av" style="background:#E4572E;">GA</div><div><div class="testi-name">Grace Adeyemi</div><div class="testi-role">Course Instructor</div></div></div>
            </div>
            <div class="testi-card" data-slide="3">
                <p class="testi-quote">Channels and DMs feel distinct at a glance. New teammates don't need a tour to find their way around.</p>
                <div class="testi-person"><div class="testi-av" style="background:#F0A63E;">PM</div><div><div class="testi-name">Priya Menon</div><div class="testi-role">Product Owner</div></div></div>
            </div>
            <div class="testi-controls">
                <button class="testi-arrow" id="testiPrev" aria-label="Previous"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3"><path d="M15 18l-6-6 6-6"/></svg></button>
                <div class="testi-dots" id="testiDots"></div>
                <button class="testi-arrow" id="testiNext" aria-label="Next"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3"><path d="M9 18l6-6-6-6"/></svg></button>
            </div>
        </div>
    </div>
</section>

<!-- FAQ -->
<section id="faq" class="lp-section">
    <div class="container-lp">
        <div class="section-head reveal">
            <span class="section-eyebrow">FAQ</span>
            <h2>Questions, answered</h2>
            <p>Can't find what you're looking for? Reach out to the team directly.</p>
        </div>
        <div class="lp-faq reveal" id="faqList">
            <div class="faq-item open">
                <button class="faq-q"><span>Is Relay Chat free to use?</span><span class="chev"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3"><path d="M6 9l6 6 6-6"/></svg></span></button>
                <div class="faq-a"><div class="faq-a-inner">Yes — this is a university software engineering project, not a commercial product. There's no billing, no paid tiers, and no credit card required.</div></div>
            </div>
            <div class="faq-item">
                <button class="faq-q"><span>What technology powers it?</span><span class="chev"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3"><path d="M6 9l6 6 6-6"/></svg></span></button>
                <div class="faq-a"><div class="faq-a-inner">ASP.NET Web Forms on .NET 4.8, Entity Framework 6 Code-First, SQL Server (LocalDB for development), Bootstrap 5, and vanilla JavaScript for interactivity. All form validations are ASP.NET server-side validator controls.</div></div>
            </div>
            <div class="faq-item">
                <button class="faq-q"><span>Does it work on mobile?</span><span class="chev"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3"><path d="M6 9l6 6 6-6"/></svg></span></button>
                <div class="faq-a"><div class="faq-a-inner">Yes — the workspace is fully responsive with a dedicated mobile flow using a slide-in sidebar and conversation column.</div></div>
            </div>
            <div class="faq-item">
                <button class="faq-q"><span>Can I create private channels?</span><span class="chev"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3"><path d="M6 9l6 6 6-6"/></svg></span></button>
                <div class="faq-a"><div class="faq-a-inner">Yes — any registered user can create a channel, becomes its owner automatically, and controls who's invited in.</div></div>
            </div>
            <div class="faq-item">
                <button class="faq-q"><span>Are passwords stored securely?</span><span class="chev"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3"><path d="M6 9l6 6 6-6"/></svg></span></button>
                <div class="faq-a"><div class="faq-a-inner">Yes — passwords are hashed with PBKDF2-SHA256 (100,000 iterations, random salt) before being stored. Plain text passwords are never persisted.</div></div>
            </div>
        </div>
    </div>
</section>

<!-- CTA BAND -->
<section class="lp-section" style="padding-top:0;">
    <div class="container-lp">
        <div class="cta-band reveal">
            <h2>Ready to start relaying?</h2>
            <p>Create an account and send your first message in under a minute.</p>
            <a href="Register.aspx" class="btn-signal btn-lg-lp">Get started free
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M5 12h14M13 5l7 7-7 7"/></svg>
            </a>
            <div class="fine">University Software Engineering Project · 2026</div>
        </div>
    </div>
</section>

<!-- FOOTER -->
<footer class="lp-footer">
    <div class="container-lp">
        <div class="row g-4">
            <div class="col-lg-4">
                <div class="d-flex align-items-center gap-2">
                    <div class="brand-mark"><svg viewBox="0 0 24 24" fill="none"><path d="M4 12c0-1.5 1-2.5 2.5-2.5S9 10.5 9 12s1 2.5 2.5 2.5S14 13.5 14 12s1-2.5 2.5-2.5S19 10.5 19 12" stroke="white" stroke-width="2" stroke-linecap="round"/></svg></div>
                    <span class="brand-word fs-5 text-white">Relay Chat</span>
                </div>
                <p class="tagline">A real-time web chat platform for teams — private messages, channels, and presence, backed by SQL Server.</p>
            </div>
            <div class="col-6 col-lg-2 footer-col">
                <h6>Product</h6>
                <a href="#features">Features</a>
                <a href="#showcase">Showcase</a>
                <a href="#how">How it works</a>
                <a href="#faq">FAQ</a>
            </div>
            <div class="col-6 col-lg-2 footer-col">
                <h6>App</h6>
                <a href="Login.aspx">Sign in</a>
                <a href="Register.aspx">Create account</a>
                <a href="Admin/AdminDashboard.aspx">Admin console</a>
            </div>
            <div class="col-6 col-lg-2 footer-col">
                <h6>Project</h6>
                <a href="#">Software Requirements Spec</a>
                <a href="#">Architecture overview</a>
                <a href="#">Course cohort</a>
            </div>
        </div>
        <div class="footer-bottom">
            <p>© 2026 Relay Chat · University Software Engineering Project</p>
            <p>ASP.NET Web Forms · Entity Framework 6 · SQL Server</p>
        </div>
    </div>
</footer>

<button class="back-to-top" id="backToTop" aria-label="Back to top">
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4"><path d="M12 19V5M5 12l7-7 7 7"/></svg>
</button>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
/* Nav scroll shadow */
const lpNav = document.getElementById('lpNav');
window.addEventListener('scroll', () => {
    lpNav.classList.toggle('scrolled', window.scrollY > 12);
    document.getElementById('backToTop').classList.toggle('show', window.scrollY > 600);
});

/* Mobile burger */
const burger = document.getElementById('lpBurger');
const mobileMenu = document.getElementById('mobileMenu');
burger.addEventListener('click', () => { burger.classList.toggle('open'); mobileMenu.classList.toggle('show'); });
mobileMenu.querySelectorAll('a').forEach(a => a.addEventListener('click', () => { burger.classList.remove('open'); mobileMenu.classList.remove('show'); }));

/* Active nav link on scroll */
const navSections = ['features','showcase','how','testimonials','faq'].map(id => document.getElementById(id)).filter(Boolean);
const navLinks = document.querySelectorAll('.lp-nav-links a');
new IntersectionObserver(entries => {
    entries.forEach(e => { if(e.isIntersecting) navLinks.forEach(a => a.classList.toggle('active', a.dataset.nav === e.target.id)); });
}, { rootMargin: '-40% 0px -50% 0px' }).observe(navSections[0] || document.body);
navSections.forEach(s => new IntersectionObserver(entries => {
    entries.forEach(e => { if(e.isIntersecting) navLinks.forEach(a => a.classList.toggle('active', a.dataset.nav === e.target.id)); });
}, { rootMargin: '-40% 0px -50% 0px' }).observe(s));

/* Reveal on scroll */
const ro = new IntersectionObserver(entries => { entries.forEach(e => { if(e.isIntersecting){ e.target.classList.add('in-view'); ro.unobserve(e.target); } }); }, { threshold: 0.15 });
document.querySelectorAll('.reveal').forEach((el, i) => { el.style.transitionDelay = (i % 3) * 0.08 + 's'; ro.observe(el); });

/* Animated counters */
function animateCount(el) {
    const target = parseInt(el.dataset.count, 10), start = performance.now(), dur = 1100;
    function tick(now) { const p = Math.min((now - start)/dur, 1); el.textContent = Math.round((1-(1-p)**3)*target); if(p<1) requestAnimationFrame(tick); }
    requestAnimationFrame(tick);
}
new IntersectionObserver((entries) => { entries.forEach(e => { if(e.isIntersecting){ animateCount(e.target); } }); }, { threshold: 0.6 })
    .observe(document.querySelector('[data-count]') || document.body);
document.querySelectorAll('[data-count]').forEach(el => {
    new IntersectionObserver(entries => { entries.forEach(e => { if(e.isIntersecting) animateCount(e.target); }); }, { threshold: 0.6 }).observe(el);
});

/* Showcase tabs */
document.querySelectorAll('.showcase-tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        document.querySelectorAll('.showcase-tab-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        document.querySelectorAll('.showcase-panel').forEach(p => p.classList.remove('active'));
        document.querySelector('.showcase-panel[data-panel="' + btn.dataset.tab + '"]').classList.add('active');
    });
});

/* Testimonial carousel */
const cards = Array.from(document.querySelectorAll('.testi-card'));
const dotsWrap = document.getElementById('testiDots');
let idx = 0;
dotsWrap.innerHTML = cards.map((_,i) => `<button class="testi-dot ${i===0?'active':''}" data-i="${i}"></button>`).join('');
const dots = Array.from(dotsWrap.children);
function showTesti(i) { idx = (i + cards.length) % cards.length; cards.forEach((c,j) => c.classList.toggle('active', j===idx)); dots.forEach((d,j) => d.classList.toggle('active', j===idx)); }
document.getElementById('testiNext').addEventListener('click', () => showTesti(idx+1));
document.getElementById('testiPrev').addEventListener('click', () => showTesti(idx-1));
dots.forEach(d => d.addEventListener('click', () => showTesti(parseInt(d.dataset.i))));
let timer = setInterval(() => showTesti(idx+1), 6000);
document.querySelector('.testi-wrap').addEventListener('mouseenter', () => clearInterval(timer));
document.querySelector('.testi-wrap').addEventListener('mouseleave', () => { timer = setInterval(() => showTesti(idx+1), 6000); });

/* FAQ accordion */
document.querySelectorAll('.faq-item').forEach(item => {
    const q = item.querySelector('.faq-q'), a = item.querySelector('.faq-a');
    if(item.classList.contains('open')) a.style.maxHeight = a.scrollHeight + 'px';
    q.addEventListener('click', () => {
        const open = item.classList.contains('open');
        document.querySelectorAll('.faq-item').forEach(x => { x.classList.remove('open'); x.querySelector('.faq-a').style.maxHeight = null; });
        if(!open) { item.classList.add('open'); a.style.maxHeight = a.scrollHeight + 'px'; }
    });
});

/* Back to top */
document.getElementById('backToTop').addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));
</script>
</body>
</html>
