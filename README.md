# Latsol SNBT Daily

A lightweight PHP 7.4 + MySQL web application for daily SNBT practice sets. Built for shared hosting with glassmorphism-inspired UI, SSE-based scoreboards, and AI-generated questions.

## Features

- Daily unique attempts (1 user + 1 device per day).
- Two modes: **Kejar Waktu** (timed) & **Santai** (relaxed).
- AI-powered question generation with structured JSON parsing.
- Real-time scoreboard and battle matchmaking via Server-Sent Events (SSE) with AJAX fallback.
- Roles: user, sepuh, moderator, admin.
- Anti-cheat checks: device binding, focus detection, rate limiting.

## Tech Stack

- PHP 7.4, PDO, procedural routing.
- MySQL 5.7/8.0 with utf8mb4.
- Vanilla JS + CSS glassmorphism theme.

## Getting Started

1. Copy `app/Config/config.php` and update database & AI credentials.
2. Import `sql/schema.sql` into your MySQL database.
3. Run `php scripts/seed_subtests.php` to populate base subtests.
4. (Optional) Schedule `php scripts/generate_daily_sets.php` via cron for automated question generation.
5. Point your web server document root to `public/` and ensure `.htaccess` rewrites are enabled.

## Development Notes

- All responses use JSON envelope `{ ok, data }`.
- SSE endpoints: `/sse/scoreboard`, `/sse/battle`.
- Fallback polling triggers when EventSource is unavailable.
- Device hash = SHA-256 of `userAgent|ipSubnet|localStorage.uuid`.

## License

MIT
