import Link from "next/link";
import { Calendar, Check, Crown, Layers, Search } from "lucide-react";
import { SectionHeading } from "@/components/section-heading";
import { Reveal } from "@/components/reveal";
import { engagementTiers } from "@/lib/content";

const icons = { search: Search, layers: Layers, calendar: Calendar, crown: Crown };

export function PricingTiers() {
  return (
    <section id="tiers" className="container-page py-24 md:py-32">
      <SectionHeading
        eyebrow="Ways to work together"
        title="Pick the level of ownership that fits where you are now."
        description="Every brand needs something different from a retention partner. Start where you are, and move up the ladder when you're ready."
      />

      <div className="mt-16 grid gap-6 md:grid-cols-2 lg:grid-cols-4">
        {engagementTiers.map((tier, i) => {
          const Icon = icons[tier.icon];
          return (
            <Reveal key={tier.title} delay={i * 0.08}>
              <div className="flex h-full flex-col overflow-hidden rounded-2xl border border-border">
                <div className="bg-foreground p-6 text-background">
                  <span className="inline-flex h-11 w-11 items-center justify-center rounded-full border border-background/30">
                    <Icon className="h-5 w-5" strokeWidth={1.75} />
                  </span>
                  <p className="mt-5 text-xs font-semibold tracking-widest text-accent-2 uppercase">
                    {tier.tag}
                  </p>
                  <h3 className="font-display mt-1 text-xl font-bold">{tier.title}</h3>
                  <p className="mt-2 text-sm leading-relaxed text-background/70">
                    {tier.tagline}
                  </p>
                </div>

                <div className="flex flex-1 flex-col bg-surface p-6">
                  <p className="text-xs font-semibold tracking-widest text-muted uppercase">
                    Best for
                  </p>
                  <p className="mt-2 text-sm leading-relaxed text-foreground/85">
                    {tier.bestFor}
                  </p>

                  <p className="mt-5 text-xs font-semibold tracking-widest text-muted uppercase">
                    You get
                  </p>
                  <ul className="mt-2 space-y-2">
                    {tier.includes.map((item) => (
                      <li key={item} className="flex items-start gap-2 text-sm text-foreground/85">
                        <Check className="mt-0.5 h-3.5 w-3.5 shrink-0 text-accent-2" strokeWidth={2.5} />
                        {item}
                      </li>
                    ))}
                  </ul>

                  <div className="mt-6 flex-1 border-t border-border pt-5">
                    <p className="font-display text-lg font-bold">{tier.priceLabel}</p>
                  </div>

                  <Link
                    href="/contact"
                    className={`mt-5 inline-flex items-center justify-center rounded-full px-5 py-3 text-sm font-semibold transition-transform hover:scale-[1.02] ${
                      tier.highlight
                        ? "bg-accent text-background"
                        : "border border-border text-foreground"
                    }`}
                  >
                    Book a Call →
                  </Link>
                </div>
              </div>
            </Reveal>
          );
        })}
      </div>
    </section>
  );
}
