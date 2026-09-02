import Link from "next/link";
import { SectionHeading } from "@/components/section-heading";
import { Reveal } from "@/components/reveal";
import { EmailFrame } from "@/components/email-frame";
import { caseStudies } from "@/lib/case-studies";

export function WorkPreview() {
  return (
    <section id="work" className="container-page py-24 md:py-32">
      <div className="flex flex-col items-start justify-between gap-6 sm:flex-row sm:items-end">
        <SectionHeading
          eyebrow="Selected work"
          title="Flows we've written, designed, and shipped."
        />
        <Link
          href="/work"
          className="hidden shrink-0 text-sm font-semibold text-accent transition-opacity hover:opacity-80 sm:inline-flex"
        >
          View all work →
        </Link>
      </div>

      <div className="mt-16 space-y-20">
        {caseStudies.map((study, i) => (
          <Reveal key={study.slug} delay={i * 0.1}>
            <div className="flex flex-col gap-8 lg:flex-row lg:gap-14">
              <div className="lg:w-72 lg:shrink-0">
                <p className="text-xs font-semibold tracking-widest text-muted uppercase">
                  {study.industry}
                </p>
                <h3 className="font-display mt-3 text-2xl font-bold">{study.client}</h3>
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
                  View case study →
                </Link>
              </div>

              <div className="grid flex-1 grid-cols-2 gap-4 sm:grid-cols-4">
                {study.pieces.map((piece) => (
                  <EmailFrame key={piece.subject} piece={piece} />
                ))}
              </div>
            </div>
          </Reveal>
        ))}
      </div>

      <Link
        href="/work"
        className="mt-12 inline-flex text-sm font-semibold text-accent hover:opacity-80 sm:hidden"
      >
        View all work →
      </Link>
    </section>
  );
}
