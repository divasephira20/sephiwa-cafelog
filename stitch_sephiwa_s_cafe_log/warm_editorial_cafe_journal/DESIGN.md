---
name: Warm Editorial Cafe Journal
colors:
  surface: '#fff8f6'
  surface-dim: '#e0d8d6'
  surface-bright: '#fff8f6'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fbf2f0'
  surface-container: '#f5ecea'
  surface-container-high: '#efe6e4'
  surface-container-highest: '#e9e1df'
  on-surface: '#1e1b1a'
  on-surface-variant: '#4f4441'
  inverse-surface: '#342f2e'
  inverse-on-surface: '#f8efed'
  outline: '#817471'
  outline-variant: '#d3c3bf'
  surface-tint: '#725951'
  primary: '#634b44'
  on-primary: '#ffffff'
  primary-container: '#7d635b'
  on-primary-container: '#ffe3db'
  inverse-primary: '#e0bfb6'
  secondary: '#685d4a'
  on-secondary: '#ffffff'
  secondary-container: '#eddec5'
  on-secondary-container: '#6c614e'
  tertiary: '#5f4c4f'
  on-tertiary: '#ffffff'
  tertiary-container: '#786467'
  on-tertiary-container: '#fee3e6'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#fddbd1'
  primary-fixed-dim: '#e0bfb6'
  on-primary-fixed: '#291711'
  on-primary-fixed-variant: '#58413a'
  secondary-fixed: '#f0e0c8'
  secondary-fixed-dim: '#d3c5ad'
  on-secondary-fixed: '#221b0b'
  on-secondary-fixed-variant: '#4f4533'
  tertiary-fixed: '#f6dcdf'
  tertiary-fixed-dim: '#d9c0c3'
  on-tertiary-fixed: '#26181a'
  on-tertiary-fixed-variant: '#544245'
  background: '#fff8f6'
  on-background: '#1e1b1a'
  surface-variant: '#e9e1df'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 15px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 18px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 10px
    fontWeight: '600'
    lineHeight: 14px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.25rem
  space-xl: 1.75rem
---

## Brand & Style
The design system embodies the intimacy, warmth, and quiet luxury of an editorial journal dedicated to cafe culture and culinary discovery. Targeted at discerning cafe hoppers, flâneurs, and lifestyle curators, the interface feels light, luminous, and tactile—evoking sunlit linen tables, fine ceramic tableware, and smooth latte froth.

The aesthetic blends **Warm Editorial Minimalism** with delicate **Tactile Softness**:
- Uncluttered compositions prioritize high-fidelity food, interior, and coffee imagery.
- Breathing space and warm alabaster planes replace dense data density.
- Subtle warmth in every tone avoids cold digital clinicalness, inspiring calm, reflective journaling and leisurely curation.

## Colors
The palette evokes artisanal patisseries, warm porcelain, and sun-drenched spaces. It relies on subtle contrast, muted earthy tones, and culinary pastel cues:

- **Canvas & Surfaces:** Base canvas sits at `#FCFBF9` (Warm Alabaster). Floating cards and elevated surfaces use `#FFFFFF` layered over subtle `#EFEAE4` (Warm Sand) hairpins and borders.
- **Brand Primary:** `#7D635B` (Muted Cocoa) anchors primary actions, elevated buttons, and active navigations, softening to `#9C8077` (Warm Taupe) on press or hover.
- **Ambient Signature Gradient:** A soft diagonal gradient (`135deg`) running from `#F7E7CE` (Soft Champagne Cream) to `#F3D9DC` (Delicate Blush Silk) is reserved for hero banners, journal milestone highlights, and profile header washes.
- **Text & Editorial Hierarchy:** High-emphasis text uses `#2E2A29` (Deep Warm Slate) to maintain contrast without the harshness of pure black. Body text and secondary descriptors use `#7A7270` (Soft Ash Gray).
- **Categorical Accents:**
  - *Visited / Completed:* `#E3EFE8` pill container with `#2C573F` deep sage text.
  - *Wishlist / Bookmarked:* `#FCEBD9` warm peach container with `#8A5229` toasted amber text.

## Typography
Plus Jakarta Sans provides balanced geometric clarity with gentle humanist warmth. It complements food photography and personal reviews while maintaining crisp legibility on compact mobile displays.

- **Display & Headlines:** Used for cafe names, curated collection titles, and journal entries. Generous line heights ensure multi-line cafe names remain light and editorial.
- **Body:** Renders taste notes, ambience impressions, and addresses with open tracking and relaxed line heights.
- **Labels & Meta:** Distinct medium and semibold weights differentiate ratings, roast profiles, timestamps, and dietary tags.

## Layout & Spacing
Designed natively for mobile portrait dimensions (390x844 standard canvas) with responsive scaling for compact and larger mobile displays:

- **Canvas Gutters & Margins:** Edge content adheres to a base `margin` of `1.25rem` (20px), preventing edge collision while maximizing screen real estate for cafe imagery. Inter-card columns use a `1rem` (16px) gutter.
- **Vertical Rhythm:** A strict 4px/8px modular rhythm governs padding and gaps. Vertical separation between feed sections is `1.75rem` (28px) to establish clear editorial breathing room.
- **Flutter Safe Area Integration:** Ensure navigation headers incorporate top safe area insets with minimum 12px interior padding; bottom navigation bars wrap system gesture bars with 16px bottom breathing room.

## Elevation & Depth
Depth is created through warm tonal contrast, soft diffused shadows, and micro-borders rather than aggressive dark drop shadows.

- **Low-Contrast Ghost Borders:** All surface cards employ a 1px border colored in `#EFEAE4` (Warm Sand), giving cards an artisanal, structured quality against the `#FCFBF9` canvas.
- **Ambient Warm Shadows:** When lifting cards or floating action buttons, use low-opacity, warm-tinted shadows:
  - *Resting Card:* `box-shadow: 0 4px 20px rgba(125, 99, 91, 0.05);`
  - *Floating Modals & Primary FABs:* `box-shadow: 0 8px 28px rgba(125, 99, 91, 0.12);`
- **Soft Light Overlays:** Sheets and modals employ a subtle frosted backdrop blur (`sigmaX: 10`, `sigmaY: 10`) tinted with `rgba(252, 251, 249, 0.8)` to preserve the cafe background atmosphere.

## Shapes
The shape language mirrors smooth ceramic ware and soft organic stones:

- **Hero & Featured Cards:** Clipped with a smooth `20px` radius for editorial prominence at the top of feeds.
- **Standard Feed & Log Cards:** Shaped with a `16px` radius for balanced image containment and comfortable touch targets.
- **Interactive Controls (Pill Form):** Primary buttons, status chips, search bars, filter tags, and bottom nav pills feature a fully rounded `50px` pill silhouette, inviting natural thumb interactions.
- **Input Fields:** Rounded to `16px` or `50px` depending on context (search bars use `50px`; multi-line journaling inputs use `16px`).

## Components

### Buttons
- **Primary Action Button:** Full 50px pill, filled with `#7D635B` (Muted Cocoa), text in `#FFFFFF`, with `0.75rem` vertical and `1.5rem` horizontal padding. On tap, scales smoothly to 0.98 with `#9C8077` background.
- **Secondary / Soft Button:** 50px pill with the signature gradient background (`#F7E7CE` to `#F3D9DC`), text in `#2E2A29`.
- **Ghost / Tertiary Button:** 50px pill, transparent background, 1px `#EFEAE4` border, text in `#7D635B`.

### Status Chips & Tags
- **"Visited" Status Tag:** 50px pill, background `#E3EFE8`, text `#2C573F`, 4px vertical / 10px horizontal padding, typography `label-sm`.
- **"Wishlist" Status Tag:** 50px pill, background `#FCEBD9`, text `#8A5229`, 4px vertical / 10px horizontal padding, typography `label-sm`.
- **Filter Chips:** 50px pill with `#FFFFFF` background, 1px `#EFEAE4` border, `#7A7270` text. Selected state switches to `#7D635B` background with `#FFFFFF` text.

### Cards
- **Featured Hero Card (20px radius):** Utilizes the signature diagonal pastel gradient wash beneath food imagery, framed with a 1px `#EFEAE4` border, featuring a 4:3 or 16:9 photo container, venue name in `headline-lg`, and floating status chip.
- **Log Feed Card (16px radius):** `#FFFFFF` fill, 1px `#EFEAE4` border, displaying a square thumbnail (72x72px, 12px radius), title in `headline-sm`, snippet in `body-md`, and date/star metrics in `label-md`.

### Input Fields & Search Bars
- **Search Input:** 50px pill, `#FFFFFF` surface, 1px `#EFEAE4` border. Leading cocoa magnifying glass icon, placeholder in `#7A7270`.
- **Journal Note Input:** 16px corner radius, `#FFFFFF` surface, 1px `#EFEAE4` border. Focused state transitions border to `#9C8077` with no heavy outline rings.

### Rating & Sensory Indicators
- **Coffee Bean / Star Rating:** Filled icon in `#7D635B`, empty state in `#EFEAE4`.
- **Vibe / Roast Profile Indicators:** Small horizontal pill badges with subtle beige backgrounds (`#F7E7CE` at 50% opacity) and `#7D635B` labels.

### Checkboxes & Selection Controls
- **Checkboxes:** 6px rounded squares with 1.5px `#EFEAE4` borders. Active state filled with `#7D635B` showing a white checkmark.
- **Radio Buttons:** Circular with `#7D635B` inner concentric circle when selected.