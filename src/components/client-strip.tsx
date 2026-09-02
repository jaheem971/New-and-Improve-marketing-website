import { caseStudies } from "@/lib/case-studies";

export function ClientStrip() {
  return (
    <section className="border-y border-border bg-surface/40">
      <div className="container-page flex flex-col items-center gap-6 py-10 sm:flex-row sm:justify-between">
        <p className="text-xs font-semibold tracking-widest text-muted uppercase">
          Real client work
        </p>
        <div className="flex flex-wrap items-center justify-center gap-x-12 gap-y-4">
          {caseStudies.map((c) => (
            <span
              key={c.slug}
              className="font-display text-lg font-medium text-foreground/70 transition-colors hover:text-foreground"
            >
              {c.client}
            </span>
          ))}
        </div>
      </div>
    </section>
  );
}
