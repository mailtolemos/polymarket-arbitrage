# Deploying to Railway

This fork is pre-configured for Railway:

- `Dockerfile` — Python 3.11 slim image, installs `requirements.txt`, runs the bot + dashboard.
- `.dockerignore` — keeps the demo `.mp4` and screenshots out of the image.
- `railway.json` — tells Railway to use the Dockerfile and restart on failure.
- `config.yaml` — switched to `trading_mode: dry_run` and `data_mode: simulation` so no real orders or wallets are involved.

## One-time setup

### 1. Fix the local repo

Whoever set this up couldn't fully initialize git from inside Cowork's sandbox, so there's a stub `.git` directory that needs to be wiped. From your terminal:

```bash
cd ~/Documents/polymarket-arbitrage
rm -rf .git
git init -b main
git add .
git commit -m "Initial commit (forked from ImMike/polymarket-arbitrage, configured for Railway)"
```

### 2. Create your GitHub repo

1. Go to https://github.com/new
2. Name it `polymarket-arbitrage` (or whatever you want)
3. Leave it empty (no README, no .gitignore — you already have those)
4. Click **Create repository**

GitHub will show you commands. Use the "push an existing repository" block:

```bash
git remote add origin https://github.com/<your-username>/polymarket-arbitrage.git
git branch -M main
git push -u origin main
```

### 3. Deploy on Railway

1. Go to https://railway.com (sign in with GitHub)
2. Click **New Project** → **Deploy from GitHub repo**
3. Pick your `polymarket-arbitrage` repo
4. Railway reads `railway.json` and starts a Docker build
5. First build takes ~3–5 minutes (installing Python deps)

### 4. Expose the dashboard

By default Railway keeps services internal. To get a public URL:

1. Open the service → **Settings** → **Networking**
2. Click **Generate Domain**
3. Railway gives you something like `polymarket-arbitrage-production.up.railway.app`
4. Open that URL — you should see the dashboard

Railway injects a `$PORT` environment variable; the Dockerfile already passes it to `run_with_dashboard.py --port $PORT` so it just works.

## What you'll see

When the bot first starts, it spends ~30–60 seconds fetching the market lists from Polymarket and Kalshi (these are **public, read-only API calls** — no credentials, no trading). During that window the dashboard URL will hang or 502.

After warmup:

- Dashboard at the Railway URL shows simulated opportunities, portfolio PnL, market counts.
- Logs in Railway's console show market fetching and arbitrage detection.
- No real money is at risk because `trading_mode: dry_run` short-circuits order placement before any HTTP call would go out.

## Cost

Railway gives you $5 of trial credits. This bot uses ~300MB RAM idle, more during market scans. Expect roughly $5–10/month on the Hobby plan if you leave it running 24/7.

## If you want fully offline simulation

To skip even the read-only Polymarket/Kalshi market list fetches, edit `config.yaml`:

```yaml
mode:
  cross_platform_enabled: false
  kalshi_enabled: false
```

Then redeploy. This is purely cosmetic for the dashboard — it won't show real market names, only synthetic ones — but eliminates all outbound HTTP.

## Going to live trading (don't, yet)

Even if you set `trading_mode: live`, the upstream code has a `TODO` in `polymarket_client/api.py` where order placement should live. Live trading is **not implemented** yet. Don't put real funds in or expose private keys until you've audited that path yourself.
