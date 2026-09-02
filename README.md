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

- `src/app` — pages: home, `/work` (+ `/work/[slug]` case studies), `/designs` (full design gallery), `/services`, `/about`, `/contact`
- `src/components` — UI building blocks (header, footer, hero, sections, email mockup frame, design gallery)
- `src/lib/case-studies.ts` — portfolio data (client, flows, email pieces) for `/work`
- `src/lib/designs.ts` — flat gallery data (any design: email, SMS, social, landing page) for `/designs`
- `src/lib/content.ts` — services, pricing tiers & process copy
- `src/lib/site.ts` — nav links, contact info, site metadata

## Adding real screenshots

Both `src/lib/case-studies.ts` (`EmailPiece`) and `src/lib/designs.ts`
(`Design`) show a styled placeholder until an entry has a real screenshot.
To swap one in:

1. Drop the image in `public/work/<client-slug>/<file>.png` (case studies)
   or `public/designs/<file>.png` (gallery)
2. Set that entry's `image` field to the matching `/work/...` or
   `/designs/...` path

The placeholder disappears automatically once `image` is set. To add a
brand-new design to the gallery that isn't part of an existing case study,
just add a new object to the `designs` array in `src/lib/designs.ts`.

## Deploying

Deploys cleanly to [Vercel](https://vercel.com/new) — connect the repo and it
will detect the Next.js app automatically.
