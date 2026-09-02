# JAH Media

Marketing site for JAH Media, a retention marketing (email & SMS) agency for
ecommerce brands. Built with Next.js (App Router), TypeScript, Tailwind CSS,
and Framer Motion.

## Getting started

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Structure

- `src/app` — pages: home, `/work` (+ `/work/[slug]` case studies), `/services`, `/about`, `/contact`
- `src/components` — UI building blocks (header, footer, hero, sections, email mockup frame)
- `src/lib/case-studies.ts` — portfolio data (client, flows, email pieces)
- `src/lib/content.ts` — services & process copy
- `src/lib/site.ts` — nav links, contact info, site metadata

## Adding real case study screenshots

Each email in `src/lib/case-studies.ts` (`EmailPiece`) shows a styled
placeholder until it has a real screenshot. To swap one in:

1. Drop the image in `public/work/<client-slug>/<file>.png`
2. Set that piece's `image` field to `/work/<client-slug>/<file>.png`

The placeholder disappears automatically once `image` is set.

## Deploying

Deploys cleanly to [Vercel](https://vercel.com/new) — connect the repo and it
will detect the Next.js app automatically.
