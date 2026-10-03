import { SectionHeading } from "@/components/section-heading";
import { Reveal } from "@/components/reveal";
import { EmailFrame } from "@/components/email-frame";
import { concepts } from "@/lib/concepts";

export function ConceptWork() {
  return (
    <section className="border-t border-border bg-surface/40 py-24 md:py-32">
      <div className="container-page">
        <SectionHeading
          eyebrow="Concept Work"
          title="Strategy concepts — not paid client work."
          description="These brands are not past or current clients. Each project below is a self-initiated concept — strategy, copy, and design, built end to end — to show how I think about a brand's lifecycle, not just how I design for one."
        />

        <div className="mt-16 space-y-20">
          {concepts.map((project, i) => {
            const flows = Array.from(new Set(project.pieces.map((p) => p.flow)));
            return (
              <Reveal key={project.slug} delay={i * 0.08}>
                <div className="flex flex-col gap-8 lg:flex-row lg:gap-14">
                  <div className="lg:w-72 lg:shrink-0">
                    <p className="text-xs font-semibold tracking-widest text-muted uppercase">
                      {project.industry}
                    </p>
                    <h3 className="font-display mt-3 text-2xl font-bold">{project.brand}</h3>
                    <p className="mt-4 text-sm leading-relaxed text-muted">{project.summary}</p>
                    <ul className="mt-5 flex flex-wrap gap-2">
                      {project.tags.map((t) => (
                        <li
                          key={t}
                          className="rounded-full border border-border px-3 py-1 text-xs text-muted"
                        >
                          {t}
                        </li>
                      ))}
                    </ul>
                    <p className="mt-6 text-xs text-muted">
                      Click any piece to zoom in and read the strategy notes.
                    </p>
                  </div>

                  <div className="flex-1 space-y-10">
                    {flows.map((flow) => (
                      <div key={flow}>
                        <h4 className="font-display text-sm font-bold text-foreground/80">
                          {flow}
                        </h4>
                        <div className="mt-4 grid grid-cols-2 gap-4 sm:grid-cols-4">
                          {project.pieces
                            .filter((p) => p.flow === flow)
                            .map((piece) => (
                              <EmailFrame key={piece.subject} piece={piece} client={project.brand} />
                            ))}
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              </Reveal>
            );
          })}
        </div>
      </div>
    </section>
  );
}
