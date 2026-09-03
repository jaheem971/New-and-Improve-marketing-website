import type { Metadata } from "next";
import Link from "next/link";
import { SectionHeading } from "@/components/section-heading";
import { Reveal } from "@/components/reveal";
import { EmailFrame } from "@/components/email-frame";
import { GeneralDesignsGrid } from "@/components/general-designs-grid";
import { CtaBand } from "@/components/cta-band";
import { caseStudies } from "@/lib/case-studies";
import { generalDesigns } from "@/lib/general-designs";

export const metadata: Metadata = {
  title: "Work — JAH Media",
  description: "Email & SMS flows written, designed, and shipped for real ecommerce brands.",
};

export default function WorkPage() {
  return (
    <>
      <section className="container-page pt-20 pb-16 md:pt-28">
        <SectionHeading
          eyebrow="Work"
          title="Real flows, for real brands."
          description="Every project below was written, designed, and built by JAH Media — no stock templates, no filler stats. Just the work."
        />
      </section>

      <section className="container-page space-y-24 pb-24 md:pb-32">
        {caseStudies.map((study, i) => (
          <Reveal key={study.slug} delay={i * 0.08}>
            <article id={study.slug} className="scroll-mt-24">
              <div className="flex flex-col gap-8 lg:flex-row lg:gap-14">
                <div className="lg:w-72 lg:shrink-0">
                  <p className="text-xs font-semibold tracking-widest text-muted uppercase">
                    {study.industry}
                  </p>
                  <h2 className="font-display mt-3 text-3xl font-bold">{study.client}</h2>
                  <p className="mt-4 text-sm leading-relaxed text-muted">{study.summary}</p>
                  <ul className="mt-5 flex flex-wrap gap-2">
                    {study.services.map((s) => (
                      <li
                        key={s}
                        className="rounded-full border border-border px-3 py-1 text-xs text-muted"
                      >
                        {s}
                      </li>
                    ))}
                  </ul>
                  <Link
                    href={`/work/${study.slug}`}
                    className="mt-6 inline-flex text-sm font-semibold text-accent hover:opacity-80"
                  >
                    Full case study →
                  </Link>
                </div>

                <div className="grid flex-1 grid-cols-2 gap-4 sm:grid-cols-4">
                  {study.pieces.map((piece) => (
                    <EmailFrame key={piece.subject} piece={piece} />
                  ))}
                </div>
              </div>
            </article>
          </Reveal>
        ))}
      </section>

      <section className="container-page pb-24 md:pb-32">
        <SectionHeading
          eyebrow="General Designs"
          title="More work, at a glance."
          description="Individual pieces that don't need the full case-study treatment — still real work, just presented straight."
        />
        <div className="mt-16">
          <GeneralDesignsGrid designs={generalDesigns} />
        </div>
      </section>

      <CtaBand />
    </>
  );
}
