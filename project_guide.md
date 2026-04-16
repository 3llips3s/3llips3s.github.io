# MISSION: THE MOTHERSHIP (STUDIO10200.DEV)
**Master Implementation Guide for Studio 10200 Portfolio**

## 1. IDENTITY & THEME ENGINE
- **Developer:** `3llips3s` | [cite_start]**Brand:** `Studio 10200` [cite: 1]
- [cite_start]**Primary Color:** Deep Purple (`#673AB7`) [cite: 1]
- **Theme Palette:**
    - [cite_start]**Dark (Default):** Pure Black (`#000000`) [cite: 1]
    - [cite_start]**Light:** Pure White (`#FFFFFF`) [cite: 2]
- **Typography:**
    - [cite_start]**Monospace/Terminal:** `JetBrains Mono` [cite: 2]
    - [cite_start]**Professional/Body:** `Inter` [cite: 2]

---

## 2. THE HERO SECTION (INTRO SEQUENCE)
### 3D Component
- [cite_start]**Asset:** `assets/3d/hoops_512.glb` [cite: 3]
- [cite_start]**Behavior:** Ambient rotation (2 RPM), No Zoom, No Camera Controls [cite: 3]
- [cite_start]**Fallback:** Pre-cache and use `assets/images/hoops_poster.webp` as a static poster during load [cite: 4]
- **3D Reveal Transition:** Fade In + Scale Up (from `scale(0)` to `scale(1)`) with a soft `cubic-bezier(0.25, 1, 0.5, 1)` curve. No sliding movement.

### Animation Handshake (Sequential)
1.  [cite_start]**Identity Scramble:** Animate the text `3llips3s` using a 1200ms character-by-character scramble[cite: 11, 12].
2.  [cite_start]**Soft Reveal:** Fade in the word `here` softly next to the locked name[cite: 13].
3.  [cite_start]**Terminal Typing:** Type out the tagline letter-by-letter: *"I build mobile & web apps @ Studio 10200"*[cite: 13, 14].
4.  **"See My Work" CTA:** Fade in and slide up a borderless text + arrow as the final sequence.
    - **Text:** "See My Work" in `Inter` font (14px, w500). Static after reveal (no ongoing animation).
    - **Arrow:** `Icons.keyboard_arrow_down_rounded` below text. Continuous soft pulse (opacity 0.4 to 1.0, 1200ms cycle).
    - **Interaction:** Both wrapped in a single `GestureDetector`. Triggers smooth scroll to the Project Registry via `Scrollable.ensureVisible` (800ms, `easeInOutCubic`).

---

## 3. PROJECT REGISTRY (LEAP-FROG GRID)
### Layout Structure
	•	Layout: Alternating "Image Left / Text Right" pattern, i.e. Alternating [Screenshot | Text]` and `[Text | Screenshot]` rows
	•	Reveal: Staggered reveal using flutter_animate. Cards slide up (20px) and fade in as they enter the viewport.
	•	Card Logic:
	◦	Visual: 16:9 AspectRatio for game screenshots (assets/screenshots/).
	◦	Text Column Hierarchy: Title (Bold JetBrains Mono) → Description (In German in Inter font) → Translation (in English in Inter font) (Smaller, 0.7 opacity, informal German "Du").
	◦	Primary Row: Large centred buttons for Play and/or Download (conditional based on project availability).
	◦	Secondary Row: Smaller icon-only buttons for Share (Native Browser Share API) and Feedback (Wiredash), aligned left of right depending on the card orientation.

### Action Logic
- [cite_start]**Primary Actions:** prominent "Play" (Web) or "Download" (APK) buttons[cite: 29, 30].
- **Direct APK Download:** Use the GitHub Latest Release URL format so users download directly from the page:
    `https://github.com/3llips3s/[repo-name]/releases/latest/download/app-release.apk`
- **Utility Row:** Small icon-only buttons for:
    - **Share:** Native browser share API (No external packages).
    - **Feedback:** Wiredash (Enable Screen Capture).

---

## 4. THE ENGINE ROOM (SYSTEM STATUS REPORT)
- **Placement:** Below the Project Registry, above the Contact section.
- **Visual Style:** 3-Column terminal grid (Stacks to 1-column on mobile). Headers: `[ 01 // CATEGORY ]`.
- **Content:**
    - `[ 01 // CORE_STACK ]`: Dart, Flutter, Flutter Flame.
    - `[ 02 // DATA_&_PERSISTENCE ]`: PostgreSQL (Supabase), Hive_ce, Shared Preferences.
    - `[ 03 // ARCHITECTURE_&_OPS ]`: Riverpod, Provider, Git/GitHub, Wiredash.
- **"Hover Decrypt" Animation:**
    - **Desktop:** Scramble tech names for 200ms on `MouseRegion` hover.
    - **Mobile:** Trigger the same scramble when the card enters the viewport via `VisibilityDetector`.
    - **Feedback:** Deep Purple (#673AB7) border glow on active items.

### GitHub CTA (Base of Engine Room)
- **Placement:** At the very bottom of the Engine Room section, below all tech columns.
- **Style:** `OutlinedButton.icon` (unlike the borderless Hero CTA, this retains an outline).
- **Icon:** `assets/images/github_icon.png` tinted white (Dark) or black (Light) via `color` property.
- **Theming:** Outline and icon/text match Engine Room palette (Deep Purple `#673AB7` or high-contrast White/Black).
- **Action:** Opens `https://github.com/3llips3s` in external browser.

---

##5. Integration & Utilities
Wiredash: - Initialize with provided Project ID & API Key.
	◦	Enable Screen Capture for feedback reports.
	◦	Theme Sync: Use Wiredash.of(context).setTheme to match the app’s Dark/Light state.
	◦	Notification Policy: Manual console check (no webhooks).
	•	Contact Section: 
      - CTA Text: "Have an idea? Let's bring it to life."
      - Animation: The CTA text should be typed out, and then the email icon and the copy clipboard icons should fade in one after the other.
	  ◦	Action 1: "Send Email" icon button (opens mail app to contact@studio10200.dev).
	  ◦	Action 2: "Copy Email" icon button (copies address to clipboard + shows confirmation tooltip).
	•	State Management: Use ValueNotifier and setState. No external state packages.
	•	Scrolling: Custom thin Deep Purple scrollbar that disappears 1.5s after scrolling stops.


## 6. ARCHITECTURE & DEPLOYMENT (UNDER ONE ROOF)
### Routing & Folders
- **Root:** `studio10200.dev` (from repo `3llips3s.github.io`).
- **Sub-projects:** Served via sub-directories (e.g., `studio10200.dev/hangmensch/`).
- **Critical Build Rule:** All sub-projects **must** be built with:
  [cite_start]`flutter build web --release --base-href "/[repo-name]/"`[cite: 8].

### Cloudflare DNS Configuration
- **A Records (@):** `185.199.108.153`, `185.199.109.153`, `185.199.110.153`, `185.199.111.153` (Proxy: Off).
- **CNAME (www):** Point to `3llips3s.github.io` (Proxy: Off).
- [cite_start]**Portfolio Repo:** Must include `web/CNAME` file containing `studio10200.dev`[cite: 7].

	•	INTERACTIVE STEP: Before final deployment, the agent must pause and walk the user through the Cloudflare DNS A-Record and CNAME setup step-by-step.
---

## 7. SECURITY & REPO HYGIENE
- **Credential Safety:** Create a `.env` file for Wiredash Project ID/API Keys.
- **Git Blocklist:** **MANDATORY** - Do not commit the following to GitHub:
    ```
    .env
    project_guide.rtf 
    loading animation_rtf
    replication_guide.md
    .antigravityrules
    agent_instructions/
    ```
- **SEO:** Update `web/index.html` with Title: `Studio 10200` and set `hoops_poster.webp` as the Open Graph preview image.
- **Build Logic:** All sub-projects **must** be built with: `flutter build web --release --base-href "/[repo-name]/"` flag.
- **Animation Timing Alignment:** All animation durations across sections must align with the Hero sequence timing constants so the entire reveal feels orchestrated. Reference: Scramble 1200ms, Here fade +400ms, Tagline 60ms/char, Model+CTA reveal +500ms after tagline, Arrow pulse 1200ms cycle.

---


## 8. CONTENT MANIFEST
| Game | Description | "Du" Translation | Platform |
| :--- | :--- | :--- | :--- |
| **Artikel Vogel** | Fly through the correct articles to keep your bird airborne. | Fliege durch die richtigen Artikel, um deinen Vogel in der Luft zu halten. | Web + APK |
| **Hangmensch** | Save the "Hangmensch" from the gallows by guessing the correct noun genders. | Rette den Hangmensch vor dem Galgen, indem du die richtigen Artikel errätst. | Web + APK |
| **Tic Tac Zwö** | Setze dein X oder O mit dem richtigen Genus und schlage deine Gegner im Solo-, Pass-and-Play- oder Online-Modus mit Bestenliste. | Claim your X or O with the correct noun gender and beat your opponents in solo, pass-and-play, or online mode with a leaderboard.
 | APK Only |
| **Wördle** | Guess the hidden German noun in six tries. | Errate das gesuchte deutsche Nomen in nur sechs Versuchen. | Web Only |

---

## 9. NAVIGATION UTILITIES
- **Back to Top:** Minimalist `Icons.keyboard_arrow_up_rounded` (Icon only) appears after 500px scroll.
- **Contact:** "Available for Freelance & Consulting" + Mail button + Copy Email button (Clipboard API).

Developer Checklist for the Agent
	1	Pre-cache: Trigger precacheImage for all screenshots and the 3D poster during the intro animation.
	2	Share API: Use html.window.navigator.share (via dart:html or js_interop) for zero-package sharing.
    3.   Include this footer/legal at the bottom of the web page: “© 2026 Studio 10200"



