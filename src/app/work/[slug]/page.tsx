import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { Reveal } from "@/components/reveal";
import { EmailFrame } from "@/components/email-frame";
import { CtaBand } from "@/components/cta-band";
import { caseStudies } from "@/lib/case-studies";

export function generateStaticParams() {
  return caseStudies.map((study) => ({ slug: study.slug }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ slug: string }>;
}): Promise<Metadata> {
  const { slug } = await params;
  const study = caseStudies.find((s) => s.slug === slug);
  if (!study) return {};
  return {
    title: `${study.client} — JAH Media`,
    description: study.summary,
  };
}

export default async function CaseStudyPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const study = caseStudies.find((s) => s.slug === slug);
  if (!study) notFound();

  const flows = Array.from(new Set(study.pieces.map((p) => p.flow)));

  return (
    <>
      <section className="container-page pt-20 pb-16 md:pt-28">
        <Link href="/work" className="text-sm text-muted hover:text-foreground">
          ← All work
        </Link>

        <Reveal className="mt-8">
          <p className="text-xs font-semibold tracking-widest text-accent uppercase">
            {study.industry}
          </p>
          <h1 className="font-display mt-4 max-w-2xl text-4xl leading-[1.05] font-bold text-balance sm:text-6xl">
            {study.client}
          </h1>
          <p className="mt-6 max-w-xl text-lg leading-relaxed text-muted">{study.summary}</p>
          <ul className="mt-6 flex flex-wrap gap-2">
            {study.services.map((s) => (
              <li
                key={s}
                className="rounded-full border border-border px-3 py-1.5 text-xs text-muted"
              >
                {s}
              </li>
            ))}
          </ul>
        </Reveal>
      </section>

      {flows.map((flow, i) => (
        <section key={flow} className="container-page pb-20">
          <Reveal delay={i * 0.05}>
            <h2 className="font-display text-xl font-bold">{flow}</h2>
            <div className="mt-6 grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
              {study.pieces
                .filter((p) => p.flow === flow)
                .map((piece) => (
                  <div key={piece.subject}>
                    <EmailFrame piece={piece} client={study.client} />
                    <p className="mt-3 text-sm leading-snug text-muted">{piece.subject}</p>
                  </div>
                ))}
            </div>
          </Reveal>
        </section>
      ))}

      <CtaBand />
    </>
  );
}
