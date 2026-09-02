import type { Metadata } from "next";
import { Reveal } from "@/components/reveal";
import { CtaBand } from "@/components/cta-band";

export const metadata: Metadata = {
  title: "About — JAH Media",
  description: "JAH Media is a retention marketing agency founded by Jaheem Hodge.",
};

const values = [
  {
    title: "Written by hand, every time",
    description:
      "No AI-generated filler, no swipe files copy-pasted across clients. Every flow and campaign is written from scratch for your brand's voice and customers.",
  },
  {
    title: "Operator, not just agency",
    description:
      "I build and market my own ecommerce brand, so I know what it feels like to watch a flow underperform — and what it takes to fix it.",
  },
  {
    title: "Retention first",
    description:
      "Acquisition gets the budget, but retention is where the margin lives. That's the only channel I work in.",
  },
];

export default function AboutPage() {
  return (
    <>
      <section className="container-page pt-20 pb-16 md:pt-28">
        <Reveal>
          <p className="text-xs font-semibold tracking-widest text-accent uppercase">About</p>
          <h1 className="font-display mt-4 max-w-3xl text-4xl leading-[1.05] font-bold text-balance sm:text-6xl">
            Retention marketing, run by someone who&apos;s actually built brands.
          </h1>
        </Reveal>
      </section>

      <section className="container-page grid gap-14 pb-24 md:grid-cols-[1fr_1.2fr] md:pb-32">
        <Reveal>
          <div className="aspect-[4/5] w-full max-w-sm overflow-hidden rounded-2xl border border-border bg-surface">
            <div
              className="flex h-full w-full items-end p-6"
              style={{ background: "linear-gradient(160deg, #12121014, #121210 75%)" }}
            >
              <div>
                <p className="font-display text-2xl font-bold">Jaheem Hodge</p>
                <p className="mt-1 text-sm text-muted">Founder, JAH Media</p>
              </div>
            </div>
          </div>
        </Reveal>

        <Reveal delay={0.1} className="max-w-xl">
          <div className="space-y-5 text-base leading-relaxed text-muted">
            <p>
              I&apos;m Jaheem Hodge — I started JAH Media because most email &amp; SMS
              &ldquo;marketing agencies&rdquo; treat retention as an afterthought: a generic
              template, a discount code, and a monthly report nobody reads.
            </p>
            <p>
              My background is in organic content and copy that actually converts, and I run
              my own ecommerce brand alongside JAH Media — so the flows I build aren&apos;t
              theoretical. They&apos;re tested on my own list before they ever reach yours.
            </p>
            <p>
              JAH Media exists to be the retention partner I wish existed when I was building
              my own brand: strategic, hands-on, and obsessed with the list as a real revenue
              channel — not a checkbox.
            </p>
          </div>

          <div className="mt-10 grid gap-8 border-t border-border pt-10 sm:grid-cols-1">
            {values.map((value) => (
              <div key={value.title}>
                <h3 className="font-display text-lg font-bold">{value.title}</h3>
                <p className="mt-2 text-sm leading-relaxed text-muted">{value.description}</p>
              </div>
            ))}
          </div>
        </Reveal>
      </section>

      <CtaBand />
    </>
  );
}
