import type { Metadata } from "next";
import { SectionHeading } from "@/components/section-heading";
import { Reveal } from "@/components/reveal";
import { PricingTiers } from "@/components/pricing-tiers";
import { ProcessSteps } from "@/components/process-steps";
import { CtaBand } from "@/components/cta-band";
import { services } from "@/lib/content";

export const metadata: Metadata = {
  title: "Services — JAH Media",
  description:
    "Email marketing, SMS marketing, lifecycle strategy, and design & copy for ecommerce brands.",
};

const details: Record<string, string[]> = {
  "Email Marketing": [
    "Welcome series",
    "Abandoned cart & checkout flows",
    "Post-purchase & win-back flows",
    "3–4 weekly campaigns",
    "Deliverability & list health",
  ],
  "SMS Marketing": [
    "List growth via popups & keywords",
    "Flow + campaign texts",
    "Compliance-safe send cadence",
    "Segmented offers by purchase behavior",
  ],
  "Lifecycle Strategy": [
    "Customer journey mapping",
    "Segmentation by behavior & value",
    "Popup & signup form strategy",
    "Offer & incentive planning",
  ],
  "Design & Copy": [
    "On-brand email templates",
    "Direct-response copywriting",
    "Subject line & offer testing",
    "Brand voice guidelines",
  ],
};

export default function ServicesPage() {
  return (
    <>
      <section className="container-page pt-20 pb-16 md:pt-28">
        <SectionHeading
          eyebrow="Services"
          title="Retention marketing, run as one system."
          description="Email and SMS aren't separate projects — they're one lifecycle system built around how your customers actually buy. Here's everything that's included."
        />
      </section>

      <PricingTiers />

      <section className="container-page pb-16">
        <SectionHeading
          eyebrow="What's included"
          title="Every tier runs on the same core capabilities."
        />
      </section>

      <section className="container-page grid gap-10 pb-24 sm:grid-cols-2 md:pb-32">
        {services.map((service, i) => (
          <Reveal
            key={service.number}
            delay={i * 0.08}
            className="rounded-2xl border border-border bg-surface p-8 md:p-10"
          >
            <span className="font-display text-sm text-accent">{service.number}</span>
            <h2 className="font-display mt-4 text-2xl font-bold">{service.title}</h2>
            <p className="mt-3 leading-relaxed text-muted">{service.description}</p>
            <ul className="mt-6 space-y-2.5 border-t border-border pt-6">
              {details[service.title]?.map((item) => (
                <li key={item} className="flex items-start gap-2.5 text-sm text-foreground/85">
                  <span className="mt-2 h-1 w-1 shrink-0 rounded-full bg-accent" />
                  {item}
                </li>
              ))}
            </ul>
          </Reveal>
        ))}
      </section>

      <ProcessSteps />
      <CtaBand />
    </>
  );
}
