---
name: Obsidian Stream
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#393939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#c1c6d7'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#8b90a0'
  outline-variant: '#414755'
  surface-tint: '#adc6ff'
  primary: '#adc6ff'
  on-primary: '#002e69'
  primary-container: '#4b8eff'
  on-primary-container: '#00285c'
  inverse-primary: '#005bc1'
  secondary: '#d1bcff'
  on-secondary: '#3c0090'
  secondary-container: '#7000ff'
  on-secondary-container: '#ddcdff'
  tertiary: '#ffb595'
  on-tertiary: '#571e00'
  tertiary-container: '#ef6719'
  on-tertiary-container: '#4c1a00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a41'
  on-primary-fixed-variant: '#004493'
  secondary-fixed: '#e9ddff'
  secondary-fixed-dim: '#d1bcff'
  on-secondary-fixed: '#23005b'
  on-secondary-fixed-variant: '#5700c9'
  tertiary-fixed: '#ffdbcc'
  tertiary-fixed-dim: '#ffb595'
  on-tertiary-fixed: '#351000'
  on-tertiary-fixed-variant: '#7c2e00'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
typography:
  display:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 34px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 30px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  margin-mobile: 20px
  gutter: 16px
  stack-sm: 4px
  stack-md: 12px
  stack-lg: 24px
  section-gap: 40px
---

## Brand & Style
The design system is built on a foundation of **Minimalism** infused with **Glassmorphism**, specifically tailored for a premium mobile media experience. The brand personality is professional and content-focused, disappearing into the background to let high-fidelity audio and video take center stage. 

The aesthetic leverages "Deep Charcoal" surfaces to provide a sophisticated, cinematic environment. Visual interest is generated through high-contrast interactive accents in "Electric Blue," while structural depth is achieved through translucent layers and background blurs rather than traditional borders or heavy shadows. The emotional response should be one of calm, focus, and technical precision.

## Colors
The palette is dominated by a true dark theme. The primary background uses a Deep Charcoal (`#121212`) to ensure pixels remain unobtrusive during media playback. 

- **Primary (Electric Blue):** Used for primary actions, progress bars, and active states.
- **Secondary (Neon Purple):** Reserved for discovery features, premium indicators, and subtle gradients in glass overlays.
- **Surface Tiers:** Semi-transparent variants of the neutral palette are used to create the glass effect, typically at 60-80% opacity with a 20px-40px backdrop blur.
- **High Contrast:** Text and iconography utilize pure white for maximum legibility against the dark void.

## Typography
The design system utilizes **Inter** exclusively to maintain a systematic, utilitarian, and modern feel. The scale is designed for high-density information environments.

- **Headlines:** Use tighter letter spacing and semi-bold weights to create a strong visual anchor.
- **Body:** Standard weight with generous line height (1.5x) to ensure metadata and descriptions are easily scannable on mobile screens.
- **Labels:** Small labels utilize slightly increased letter spacing and an uppercase transform for secondary metadata (e.g., "ALBUM," "DURATION") to provide stylistic variety without introducing a second typeface.

## Layout & Spacing
This design system employs a **Fluid Grid** model based on an 8px square rhythm. For mobile, the standard side margin is 20px to allow content to breathe while maintaining a focused vertical column.

- **Vertical Rhythm:** Elements are grouped using 4px (tight), 12px (standard), and 24px (loose) stacks. 
- **Media Containers:** Video players and album art should maintain a consistent aspect ratio (16:9 for video, 1:1 for audio) and span the full width of the margins.
- **Safe Areas:** Ensure interactive elements are placed at least 44px from the bottom edge of the device to account for system navigation gestures.

## Elevation & Depth
Depth is communicated through **Glassmorphism** and tonal layering rather than shadows. 

1. **Base Layer:** The deepest level is the `#121212` background.
2. **Surface Layer:** Cards and secondary containers use `#1E1E1E` with no blur.
3. **Glass Layer:** Navigation bars, bottom sheets, and floating players use a semi-transparent background (60% opacity) with a `backdrop-filter: blur(24px)`.
4. **Outlines:** Instead of shadows, use a 1px "inner glow" or "ghost border" (White at 10% opacity) on glass elements to define their edges against the dark background.

## Shapes
The shape language is consistently **Rounded**. This softens the "technical" feel of the dark theme, making the app feel more approachable.

- **Small elements (Chips, Tags):** Use 0.5rem (8px).
- **Standard containers (Cards, Input Fields):** Use 1rem (16px).
- **Large containers (Bottom Sheets, Modal Overlays):** Use 1.5rem (24px) on the top corners to create a distinct nesting effect.
- **Media Play Buttons:** Use a perfect circle to differentiate interactive media controls from structural UI.

## Components
- **Buttons:** Primary buttons are solid Electric Blue with white text. Secondary buttons are "Ghost" style with a 1px white border at 20% opacity.
- **Input Fields:** Search and text inputs use the Surface Layer color (`#1E1E1E`) with a subtle 1px border that glows Electric Blue when focused.
- **Thin-Line Icons:** Use a 1.5px stroke weight for all icons. Icons should never be filled unless they represent an "active" or "selected" state.
- **Media Progress Bar:** A thin (2px) line in grey with a high-contrast Electric Blue fill for the elapsed portion. The "scrubber" handle only appears during active touch.
- **Cards:** Content cards (movies, albums) should have no visible border; the image fills the container to the 16px corner radius.
- **Glass Navigation:** The bottom navigation bar must be a blurred glass element to allow the content to peek through as the user scrolls, maintaining a sense of space.