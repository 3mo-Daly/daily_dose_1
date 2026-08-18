# Elagy — Logo Concepts

Six logo directions for the Elagy medicine-reminder app. Each is a real `.svg` file you can use as-is for the app icon, or hand to a designer / AI image generator as a starting point.

**Open `preview.html` in a browser to see them all side-by-side at multiple sizes.**

---

## Design constraints I followed

- **Brand color**: `#10B981` (emerald) primary, `#82CBAE` (sage) secondary — matches your existing `app_theme.dart`.
- **Senior-friendly**: large rounded shapes, no thin details that disappear at small sizes, high contrast.
- **Bilingual**: no embedded English/Arabic text in the icons themselves (works in both locales).
- **App-icon ready**: 512×512 square viewBox with 120px corner radius (iOS/Android style).
- **Single focal point** so the icon reads instantly on a crowded home screen.

---

## The six concepts

| # | Name | Strength | Best if you want to emphasize... |
|---|---|---|---|
| 1 | **Caring Capsule** | Most direct "this is a pill app" | Medication itself |
| 2 | **Family Care** | Shows multi-profile feature | Family / caregiver use case |
| 3 | **Daily Sun** | Warm, friendly, unambiguous medical | Daily routine, senior comfort |
| 4 | **Heart Pulse** | Most emotional / human | Care, well-being |
| 5 | **Pill Clock** | Emphasizes timing / reminders | "Never miss a dose" |
| 6 | **"E" Monogram** | Strongest brand identity | Building a recognizable brand |

**My top picks for your specific app:**
- **#3 Daily Sun** — best for senior accessibility, instantly readable.
- **#6 "E" Monogram** — best for a brand that scales (App Store, splash screen, marketing).
- **#1 Caring Capsule** — best if you want to keep it simple and literal.

---

## Converting SVG → PNG for `pubspec.yaml` / `flutter_launcher_icons`

If you want PNG versions (Flutter usually wants `assets/icon.png` at 1024×1024):

```bash
# Using Inkscape (free):
inkscape 3_daily_sun.svg --export-type=png --export-width=1024 --export-filename=icon.png

# Or using ImageMagick:
magick convert -background none -resize 1024x1024 3_daily_sun.svg icon.png

# Or just open the SVG in a browser, screenshot, and resize — works fine for a first pass.
```

Then add to `pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon.png"
  adaptive_icon_background: "#10B981"
  adaptive_icon_foreground: "assets/icon_foreground.png"
```

Then run: `flutter pub run flutter_launcher_icons`

---

## AI Image Generator Prompts (Midjourney / DALL-E / Imagen / Firefly)

If you want polished, illustrated variants of any of these concepts, paste the prompts below into your generator of choice. All include the brand colors and "app icon" framing so the output is usable.

### Prompt for #1 — Caring Capsule
```
Minimalist flat app icon, rounded square with emerald green background (#10B981),
white pharmaceutical capsule pill tilted at 30 degrees in the center,
left half of capsule in soft sage green (#82CBAE), right half pure white,
small white heart symbol floating above the capsule,
clean vector style, soft drop shadow, no text, centered composition, 1024x1024
```

### Prompt for #2 — Family Care
```
Modern flat app icon, soft off-white background, vertical emerald-green pill capsule
in the center, three small abstract human silhouettes (head + shoulders) arranged
around the pill in soft sage green, friendly geometric shapes, no faces,
representing family medicine reminder app, rounded square 1024x1024, no text
```

### Prompt for #3 — Daily Sun (my recommendation)
```
Minimalist flat app icon, cream-white rounded square background,
emerald green sun in the center with 8 simple radiating rays,
white medical cross inside the sun circle,
warm and welcoming, designed for senior users, high contrast,
vector illustration, no text, 1024x1024 app icon format
```

### Prompt for #4 — Heart Pulse
```
Flat app icon, emerald green (#10B981) rounded square background,
large white heart shape in center, green ECG heartbeat line cutting through
the heart horizontally, peaks and valleys representing pulse,
clean minimal style, medical reminder app, no text, 1024x1024
```

### Prompt for #5 — Pill Clock
```
Modern flat app icon, emerald green rounded square background,
white circular clock face in the center, the hour hand is a green
pharmaceutical capsule pill instead of a regular hand,
simple hour markers (12, 3, 6, 9), thin minute hand, designed to convey
"medicine reminder on time", vector style, no text, 1024x1024
```

### Prompt for #6 — Elagy "E" Monogram
```
Minimalist app icon, emerald green (#10B981) rounded square background,
bold white capital letter "E", the middle horizontal stroke of the E is
stylized as a two-tone pharmaceutical capsule (half sage green, half white),
strong brand identity, geometric, vector style, no other text, 1024x1024
```

---

## Want a different direction?

Tell me which concept feels closest and what you'd change (color, mood, more playful, more clinical, more Arabic/cultural elements, etc.) and I'll iterate on the SVG directly.
