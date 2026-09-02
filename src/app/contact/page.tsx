import type { Metadata } from "next";
import { Reveal } from "@/components/reveal";
import { ContactForm } from "@/components/contact-form";
import { site } from "@/lib/site";

export const metadata: Metadata = {
  title: "Contact — JAH Media",
  description: "Book a free retention audit with JAH Media.",
};

export default function ContactPage() {
  return (
    <section className="container-page grid gap-16 pt-20 pb-24 md:grid-cols-[1fr_1.1fr] md:pt-28 md:pb-32">
      <Reveal>
        <p className="text-xs font-semibold tracking-widest text-accent uppercase">Contact</p>
        <h1 className="font-display mt-4 text-4xl leading-[1.05] font-bold text-balance sm:text-5xl">
          Let&apos;s look at your flows.
        </h1>
        <p className="mt-6 max-w-md leading-relaxed text-muted">
          Tell me a bit about your brand and where retention stands today. I&apos;ll reply
          personally — no sales team, no automated sequence.
        </p>

        <div className="mt-10 space-y-3 border-t border-border pt-8">
          <p className="text-sm text-muted">Prefer email?</p>
          <a href={`mailto:${site.email}`} className="text-lg font-semibold text-accent">
            {site.email}
          </a>
        </div>
      </Reveal>

      <Reveal delay={0.1} className="rounded-2xl border border-border bg-surface p-6 md:p-10">
        <ContactForm />
      </Reveal>
    </section>
  );
}
