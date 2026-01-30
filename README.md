# Aahar

Your desi gym bro calorie tracker that roasts you for eating junk. Because MyFitnessPal doesn't guilt-trip you in Hinglish.

## Features

- **AI Food Scanner** — Snap a photo, AI tells you the macros. Yes, it knows that's a samosa, not a "light snack"
- **Description Mode** — Add context before analysis so the AI doesn't mistake your poha for scrambled eggs
- **Manual Entry** — For when you're too ashamed to photograph your 3am Maggi
- **Edit & Delete** — Made a mistake? Swipe to fix. Ate something you regret? Can't help with that, but you can delete the log
- **Macro Tracking** — Calories, protein, carbs, fat + optional micros (fiber, sugar, sodium, iron, calcium, vitamin D)
- **Emoji Tags** — Because every meal deserves a tiny emotional label
- **Streaks & XP** — Gamification to keep you logging dal chawal like it's a competitive sport
- **Multiple AI Models** — Switch between Gemini Flash, Flash Lite, and Pro depending on your budget and patience

## Setup

```bash
flutter pub get
```

Create `.env` at project root:
```
GEMINI_API_KEY=your_api_key_here
```

Get your key from [Google AI Studio](https://aistudio.google.com/apikey). It's free. Like the gym membership you're not using.

```bash
flutter run
```

## Tech Stack

| What | Why |
|------|-----|
| Flutter | Cross-platform, one codebase to rule them all |
| Riverpod | State management that doesn't make you cry |
| Hive | Local DB, fast like your metabolism used to be |
| Gemini API | Google's AI does the food math so you don't have to |
| Dio | HTTP client for talking to the AI overlords |
| Clean Architecture | Because we're civilized |

## Models

| Model | Speed | Accuracy | Free Tier |
|-------|-------|----------|-----------|
| Gemini 2.0 Flash | Fast | Good | Yes |
| Gemini 2.0 Flash Lite | Fastest | Decent | Yes |
| Gemini 2.5 Pro | Slow | Best | No (zero quota) |

Use Flash (default) unless you enjoy 429 errors.

## Screenshots

Coming soon. The app looks better than your diet.

## Contributing

PRs welcome. Bugs? Open an issue. Feature ideas? Also open an issue. Want to argue about tabs vs spaces? Please don't.

## License

Do whatever you want with it. Just don't blame us when it tells you that biryani is 800 calories. (It is.)
