---
name: Arun Invoice Pro
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#45464d'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#76777d'
  outline-variant: '#c6c6cd'
  surface-tint: '#565e74'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#131b2e'
  on-primary-container: '#7c839b'
  inverse-primary: '#bec6e0'
  secondary: '#904d00'
  on-secondary: '#ffffff'
  secondary-container: '#fe932c'
  on-secondary-container: '#663500'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#002114'
  on-tertiary-container: '#069669'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2fd'
  primary-fixed-dim: '#bec6e0'
  on-primary-fixed: '#131b2e'
  on-primary-fixed-variant: '#3f465c'
  secondary-fixed: '#ffdcc3'
  secondary-fixed-dim: '#ffb77d'
  on-secondary-fixed: '#2f1500'
  on-secondary-fixed-variant: '#6e3900'
  tertiary-fixed: '#85f8c4'
  tertiary-fixed-dim: '#68dba9'
  on-tertiary-fixed: '#002114'
  on-tertiary-fixed-variant: '#005137'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 36px
    fontWeight: '800'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: '800'
    lineHeight: 36px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.05em
  numeric-table:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-tablet: 1.5rem
  margin-desktop: 2.5rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system is tailored for fast-paced commercial trade, logistics, and enterprise billing. It translates the dense, structured utility of traditional paper invoices into an agile, modern, touch-first mobile and desktop application. 

The aesthetic sits at the intersection of **Corporate Modern** and **High-Density Utilitarian Minimalism**. It delivers uncompromising visual clarity, strict data alignment, and fast transactional ergonomics. The emotional tone projects absolute reliability, fiscal authority, and frictionless operational speed. 

Key attributes:
- **Touch-First Utility:** Prioritizes 44px+ interactive targets, bottom-anchored action sheets, and thumb-friendly quick actions for warehouse floors, field sales, and on-the-go reconciliation.
- **Architectural Structure:** Inspired by structured billing slips and ledger matrices, utilizing disciplined surface tiers and subtle dividers rather than heavy visual clutter.
- **Information Hierarchy:** High-contrast key figures (totals, invoice IDs, balance dues) take front stage, supported by clean geometric typography and monospaced tabular figures.

## Colors

The palette grounds high-stakes financial operations with deep institutional slate navies, bright paper-white canvases, and purposeful industrial amber accents. Status signaling follows strict universal conventions for instant invoice status recognition.

### Palette Architecture
- **Primary Canvas & Surfaces:** Pure White (`#FFFFFF`) serves as the base for modular ledger cards, set against an off-white background tier (`#F8FAFC`) with subtle section grounding (`#F1F5F9`).
- **Deep Navy / Dark Charcoal (`#0F172A`, `#111827`):** Primary color applied to top navigation bars, key fiscal summaries, dominant buttons, and primary typography.
- **Industrial Warm Amber (`#D97706`, `#F59E0B`, `#FEF3C7`):** The operational accent color. Communicates action items, partial settlements, pending dispatches, and selective interactive focus states.
- **Status & Feedback Tokens:**
  - **Paid / Cleared (`#059669`, Surface: `#ECFDF5`):** Clear emerald confirmation.
  - **Partial / Pending (`#D97706`, Surface: `#FFFBEB`):** Warm amber cautionary state.
  - **Overdue / Cancelled (`#DC2626`, Surface: `#FEF2F2`):** Crisp rose red urgency.
- **Borders & Dividers:** Precise slate lines (`#E2E8F0`) maintain structural legibility without visual fatigue.

## Typography

The typographic hierarchy pairs **Plus Jakarta Sans** for commanding, modern headers with **Inter** for dense transactional UI, itemized tables, and input groups.

All currency readouts, rates, quantities, HSN codes, and invoice numbers must activate tabular numeric figures (`font-variant-numeric: tabular-nums` or `fontFeatureSettings: '"tnum" 1'`) to ensure vertical decimal alignment across line items and grand totals.

Section headers on invoices and overview cards should make disciplined use of uppercase micro-labels (`label-sm`) with tracking (+0.05em) to echo traditional invoice ledger headers (e.g., `BUYER DETAILS`, `TAX BREAKUP`, `BANK DETAILS`).

## Layout & Spacing

This design system uses a responsive fluid grid with strict vertical balance based on a 4px/8px modular rhythm.

### Breakpoints & Adaptive Layout
- **Mobile (< 768px):** Single-column stacked stream. Main content margins are `1rem` (16px). Actions dock to a persistent bottom utility bar (`min-height: 64px`) to preserve single-thumb reachability. Invoice line items reflow from a table into individual modular touch-cards.
- **Tablet (768px - 1024px):** 8-column layout with `1.5rem` margins. Line items transition into compact multi-column data lists with inline editing.
- **Desktop (> 1024px):** 12-column layout with `2.5rem` margins and maximum container constraint of `1280px`. Left/center spans handle the document creation canvas and dynamic receipt preview, while the right 4 columns house persistent billing summaries, audit history, and dispatch controls.

All touch elements preserve minimum boundaries of 44px by 44px on mobile devices.

## Elevation & Depth

Visual hierarchy uses a refined hybrid of **tonal surface layering** and **low-contrast micro-borders**, paired with minimal ambient drop shadows for overlay states. This prevents visually muddy screens when rendering dense line item tables.

### Layer Tiers
- **Canvas Base (Level 0):** Background tone `#F8FAFC`. Zero elevation, non-interactive.
- **Container / Ledger Cards (Level 1):** Solid `#FFFFFF` fill, bordered with `1px solid #E2E8F0`. Shadow: `0 1px 2px 0 rgba(15, 23, 42, 0.05)`.
- **Active / Interactive Hover Cards (Level 2):** Subtle translation with `box-shadow: 0 4px 6px -1px rgba(15, 23, 42, 0.08), 0 2px 4px -2px rgba(15, 23, 42, 0.04)`.
- **Floating Modals, Drawers & Sticky Mobile Footers (Level 3):** Grounded by a dark-tinted directional blur: `box-shadow: 0 -4px 12px rgba(15, 23, 42, 0.08)` for bottom sheets, and `0 20px 25px -5px rgba(15, 23, 42, 0.1)` for centered modal dialogs.
- **Focus Rings:** Non-inset `2px` ring in `#D97706` offset by `2px` white space for crisp accessibility.

## Shapes

The design system adopts a balanced **Rounded** shape language (`roundedness: 2`). This tempers strict corporate tabular data with inviting tactile shapes suited for mobile interfaces.

### Curvature Tokens
- **Micro Elements (Badges, Status Chips, Checkboxes):** `rounded-md` (`0.375rem` / 6px) to maintain geometric sharpness.
- **Input Fields, Action Buttons, Select Dropdowns:** `rounded-lg` (`0.5rem` / 8px) balancing thumb comfort and crisp structural alignment.
- **Cards, Table Containers, Item Modules:** `rounded-xl` (`1rem` / 16px) creating cleanly segmented chunks of business data.
- **Sheet Surfaces & Floating Bar Outer Boundaries:** `rounded-2xl` (`1.5rem` / 24px) on top edges for mobile drawer drawers.

## Components

### Buttons & Quick Actions
- **Primary Button:** Dark Charcoal (`#0F172A`) solid background, pure white text, 48px height on touch devices, with `label-lg` typography. Active tap scale: `transform: scale(0.98)`.
- **Accent Action Button:** Industrial Amber (`#D97706`) background, white text. Reserved for primary conversion states like "Collect Payment" or "Generate E-Way Bill."
- **Secondary Button:** Surface `#FFFFFF` with `1px solid #E2E8F0`, dark charcoal text. Hover/focus shifts background to `#F1F5F9`.
- **Sticky Mobile Action Bar:** Fixed to viewport bottom with high-tier elevation, safe-area inset padding, presenting secondary and primary CTA side-by-side or stacked.

### Form Inputs & Currency Fields
- **Container:** Minimum height 48px, background `#FFFFFF`, border `1px solid #CBD5E1`, rounded `0.5rem`.
- **Currency Entry Groups:** Dedicated left prefix pill (e.g., `₹`, `$`) styled with `#F1F5F9` background and `#64748B` typography, immediately adjoining tabular numeral input with right-aligned text.
- **Labeling:** Floating or top micro-labels in uppercase `label-sm` with slate color `#64748B`.

### Status Badges & Chips
- Compact pill-shaped elements (`rounded-full`, padding `0.25rem 0.75rem`).
- **Paid:** Border `#A7F3D0`, background `#ECFDF5`, text `#065F46`. Includes a 6px solid emerald dot prefix.
- **Partial / Pending:** Border `#FDE68A`, background `#FFFBEB`, text `#92400E`.
- **Overdue:** Border `#FECACA`, background `#FEF2F2`, text `#991B1B`.

### Invoice Line Item Cards (Mobile & Responsive)
- On screens under 768px, traditional table rows convert into modular touch-cards (`rounded-xl`, `border: 1px solid #E2E8F0`).
- Card header contains Item Name and Total Amount in bold tabular figures.
- Card body reveals two-column sub-metrics: HSN Code, Quantity, and Unit Rate.
- Card actions feature quick inline stepper buttons (+ / -) and a swipe-to-delete contextual action.

### Ledger Summary Panel
- A distinct high-density container using `#F8FAFC` background with a `#0F172A` accent bar.
- Rows for Subtotal, Tax Breakdown (e.g., CGST, SGST, IGST), and Adjustments use muted typography.
- Grand Total is highlighted with deep navy background (`#0F172A`), white text, and prominent `headline-lg` numeric weight.