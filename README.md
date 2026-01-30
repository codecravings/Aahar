# Aahar

Your desi gym bro calorie tracker that roasts you for eating junk.

## What it does

- Snap a photo of your food, AI tells you the macros (and judges you)
- Manual entry for when you're too ashamed to photograph your 3am Maggi
- Tracks calories, protein, carbs, fat + optional micro-nutrients
- Streaks, XP, achievements — because apparently we need gamification to eat dal chawal
- Hinglish motivation engine that sounds like your gym buddy

## Setup

```bash
flutter pub get
```

Create `.env` at project root:
```
GEMINI_API_KEY=your_api_key_here
```

```bash
flutter run
```

## Tech

Flutter + Riverpod + Hive + Gemini API. Clean architecture because we're civilized.

## Note

Gemini 2.5 Pro has **zero** free tier quota. Use Flash (default) or Flash Lite unless you have a paid plan.
