---
name: Manchitra
colors:
  surface: "#fbf9f5"
  surface-dim: "#dbdad6"
  surface-bright: "#fbf9f5"
  surface-container-lowest: "#ffffff"
  surface-container-low: "#f5f3ef"
  surface-container: "#efeeea"
  surface-container-high: "#eae8e4"
  surface-container-highest: "#e4e2de"
  on-surface: "#1b1c1a"
  on-surface-variant: "#5b403d"
  inverse-surface: "#30312e"
  inverse-on-surface: "#f2f0ed"
  outline: "#8f6f6c"
  outline-variant: "#e4beba"
  surface-tint: "#ba1a20"
  primary: "#af101a"
  on-primary: "#ffffff"
  primary-container: "#d32f2f"
  on-primary-container: "#fff2f0"
  inverse-primary: "#ffb3ac"
  secondary: "#785900"
  on-secondary: "#ffffff"
  secondary-container: "#fdc003"
  on-secondary-container: "#6c5000"
  tertiary: "#a22456"
  on-tertiary: "#ffffff"
  tertiary-container: "#c23e6e"
  on-tertiary-container: "#fff1f3"
  error: "#ba1a1a"
  on-error: "#ffffff"
  error-container: "#ffdad6"
  on-error-container: "#93000a"
  primary-fixed: "#ffdad6"
  primary-fixed-dim: "#ffb3ac"
  on-primary-fixed: "#410003"
  on-primary-fixed-variant: "#930010"
  secondary-fixed: "#ffdf9e"
  secondary-fixed-dim: "#fabd00"
  on-secondary-fixed: "#261a00"
  on-secondary-fixed-variant: "#5b4300"
  tertiary-fixed: "#ffd9e1"
  tertiary-fixed-dim: "#ffb1c5"
  on-tertiary-fixed: "#3f001b"
  on-tertiary-fixed-variant: "#8b0e45"
  background: "#fbf9f5"
  on-background: "#1b1c1a"
  surface-variant: "#e4e2de"
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: "700"
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: "600"
    lineHeight: 40px
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: "600"
    lineHeight: 32px
  body-lg:
    fontFamily: Manrope
    fontSize: 18px
    fontWeight: "400"
    lineHeight: 28px
  body-md:
    fontFamily: Manrope
    fontSize: 16px
    fontWeight: "400"
    lineHeight: 24px
  label-lg:
    fontFamily: Manrope
    fontSize: 14px
    fontWeight: "600"
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Manrope
    fontSize: 12px
    fontWeight: "500"
    lineHeight: 16px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  unit: 4px
  container-padding: 24px
  stack-gap: 16px
  section-margin: 32px
  card-inset: 20px
---

## Brand & Style

The brand personality of this design system is **Festive Luxury**. It is designed to evoke the spiritual grandiosity and vibrant energy of Durga Puja through a lens of modern sophistication. The target audience is the discerning urban traveler and cultural enthusiast who seeks an effortless, premium navigation experience amidst the festival's chaos.

The visual style is a hybrid of **Apple’s Human Interface** (clarity, precision, and depth) and **Google’s Material 3** (expressive color and dynamic shapes). We employ a **Glassmorphic** layer strategy to simulate the ethereal quality of _Kash_ flowers and morning mist in the light theme, and the glowing radiance of pandal lights against the midnight sky in the dark theme. Subtle Bengali motifs, such as stylized lotus curves and Alpana-inspired geometric patterns, are integrated as background textures and animated particles to ground the high-tech AI capabilities in cultural heritage.

## Colors

This design system utilizes a dual-thematic palette inspired by the transition of the festival from day to night.

**Light Theme (Morning Puja):**
The foundation is **Temple Beige (#FDFBF7)**, providing a warm, ivory-like canvas. **Deep Vermillion** is the primary action color, symbolizing the _Sindoor_ and traditional energy. **Soft Gold** and **Lotus Pink** serve as accents for secondary interactions and status indicators, creating a soft, celebratory atmosphere.

**Dark Theme (Festival Glow):**
The background shifts to **Midnight Black**, accented by **Royal Blue** depths. **Golden Amber** becomes the primary color to mimic the glow of lamps. **Neon Cyan** is introduced for AI-driven navigation paths, providing high-contrast visibility against the dark, festive night.

The glassmorphic elements use high-transparency fills with a heavy background blur to maintain legibility while allowing the animated festival particles to peak through the UI layers.

## Typography

The typography strategy balances modern legibility with high-end editorial flair. **Plus Jakarta Sans** is used for all headlines and display text; its soft, rounded terminals echo the friendly and welcoming nature of the festival. For body copy and functional labels, **Manrope** provides a geometric, balanced structure that ensures clarity during navigation.

For Bengali script support, the system defaults to a sophisticated, high-contrast serif that complements the English headlines, ensuring that local pandal names and descriptions feel integrated rather than secondary. Large display titles should use tighter letter spacing to maintain a "luxury brand" aesthetic.

## Layout & Spacing

This design system employs a **Fluid Grid** model with generous safe areas to reinforce the premium feel. On mobile, we use a 24px outer margin to prevent the UI from feeling "crowded," which is essential given the busy environments the app will be used in.

Spacing follows a 4px base unit, but primary components are separated by 16px (Stack Gap) or 32px (Section Margin) to allow the "Floating Card" architecture to breathe. The layout is optimized for one-handed use, with interactive elements positioned within the "thumb zone" and high-level pandal information presented in expansive, easy-to-read cards.

## Elevation & Depth

Depth is the core of this design system's hierarchy. Rather than traditional hard shadows, we use **Tonal Layers** and **Ambient Glows**.

1.  **The Base:** The solid background (Beige or Midnight).
2.  **Floating Cards:** Surface layers with a 20% opacity white (Light) or 10% white (Dark) tint, featuring a 24px backdrop blur.
3.  **Active Elements:** Primary buttons and high-priority cards feature a subtle "outer glow" in the primary accent color (Vermillion or Amber) instead of a black shadow.
4.  **Particles:** 3D animated particles (petals or sparks) float between the base and the glass layers, creating a sense of physical immersion.

## Shapes

The shape language is extremely organic and soft. Following the **Roundedness Level 3** specification, the minimum corner radius for standard components is 24px. Large containers and primary floating cards use a 32px radius to mimic the smooth, continuous curves found in temple architecture and lotus petals. Buttons are consistently pill-shaped to provide a clear, tactile affordance that stands out against the rectangular information cards.

## Components

**Buttons & Action Elements**
Primary buttons are pill-shaped with a slight gradient fill (Vermillion-to-Orange). The "Hop" button—the primary AI navigation trigger—is a large, circular floating action button (FAB) featuring a 3D **Dhunuchi** (ritual incense burner) icon.

**Glass Cards**
Pandal details are housed in floating glass cards. These must have a 1px inner border (white at 20% opacity) to catch the light and define the edges against complex background textures.

**Custom Bengali Icons**
Standard iconography is replaced with culturally contextual symbols:

- **Pandal/Navigation:** Stylized temple silhouette.
- **Crowd Levels:** A series of "Dhak" (drum) icons that fill up as crowd density increases.
- **Transit:** A minimalist Kolkata Metro symbol.
- **Favorites:** A lotus blossom icon instead of a heart.

**Input Fields**
Inputs are borderless glass containers with a subtle underline in Soft Gold. Focus states are indicated by an increase in the background blur intensity and a pulsating amber cursor.

**Lists & Navigation**
The bottom navigation bar is a detached, floating glass "dock" with a 40px roundedness, mirroring the Apple HIG dock aesthetic but adapted for the festival's vibrant color palette.
