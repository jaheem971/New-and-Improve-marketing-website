import { SectionHeading } from "@/components/section-heading";
import { Reveal } from "@/components/reveal";
import { services } from "@/lib/content";

export function ServicesGrid() {
  return (
    <section id="services" className="container-page py-24 md:py-32">
      <SectionHeading
        eyebrow="What we do"
        title="Retention marketing, handled end to end."
        description="Email and SMS aren't side channels — they're the system that keeps customers coming back. We run all of it."
      />

      <div className="mt-16 grid gap-px overflow-hidden rounded-2xl border border-border bg-border sm:grid-cols-2">
        {services.map((service, i) => (
          <Reveal key={service.number} delay={i * 0.08} className="bg-background p-8 md:p-10">
            <span className="font-display text-sm text-accent">{service.number}</span>
            <h3 className="font-display mt-4 text-2xl font-bold">{service.title}</h3>
            <p className="mt-3 leading-relaxed text-muted">{service.description}</p>
          </Reveal>
        ))}
      </div>
    </section>
  );
}
