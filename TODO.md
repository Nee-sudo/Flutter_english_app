# UI Improvement TODO (Phases 1–2)

## Plan baseline
- No new pages/routes.
- Improve design system + typography + colors + dark theme foundation.
- Redesign homepage and story list/cards.
- Add consistent components (cards/buttons/inputs), smoother transitions.
- Upgrade story reader UI (reader mode/progress/TOC/glossary inline).
- Redesign paywall modal (benefits + better validation + slide-in animation).
- Refresh admin dashboard UI (layout/cards/charts-lite/date range).

## Steps
- [x] Step 1: Update `lib/utils/constants.dart` (expanded palette, semantic colors, spacing/radii/elevation/animation tokens)

- [x] Step 2: Update `lib/main.dart` (theme typography, input decoration theme, light+dark ColorSchemes, themeMode hook)

- [ ] Step 3: Update `lib/widgets/app_card.dart` (shadow/interaction polish)
- [ ] Step 4: Update `lib/widgets/tense_card.dart` (story count/progress/badges + 200–300ms micro-interactions)
- [ ] Step 5: Update `lib/screens/home_screen.dart` (hero + CTA + featured/demo section + search/filter + improved tense grid)
- [ ] Step 6: Update `lib/screens/story_view_screen.dart` (better story cards, unlock/demo indicators, progress indicator, back-to-home button, empty states)
- [ ] Step 7: Update `lib/widgets/story_display.dart` (reader mode, readability spacing/line-length constraints, inline glossary hints)
- [ ] Step 8: Update `lib/widgets/paywall_modal.dart` (benefits/products/testimonials list + inline validation + slide-in animation)
- [ ] Step 9: Update `lib/screens/admin_dashboard_screen.dart` (dashboard layout polish + lightweight charts + date range picker UI)
- [ ] Step 10: Run `flutter analyze` and `flutter run` smoke checks (mobile/tablet/desktop responsive)

