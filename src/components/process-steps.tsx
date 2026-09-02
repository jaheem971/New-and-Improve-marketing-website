import { SectionHeading } from "@/components/section-heading";
import { Reveal } from "@/components/reveal";
import { process } from "@/lib/content";

export function ProcessSteps() {
  return (
    <section id="process" className="border-t border-border bg-surface/40 py-24 md:py-32">
      <div className="container-page">
        <SectionHeading
          eyebrow="How it works"
          title="A simple process, run the same way every time."
        />

        <div className="mt-16 grid gap-8 md:grid-cols-4 md:gap-6">
          {process.map((step, i) => (
            <Reveal key={step.number} delay={i * 0.1}>
              <div className="flex flex-col">
                <span className="font-display text-4xl font-bold text-accent">
                  {step.number}
                </span>
                <h3 className="font-display mt-4 text-xl font-bold">{step.title}</h3>
                <p className="mt-3 text-sm leading-relaxed text-muted">{step.description}</p>
              </div>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  );
}
