import type { Metadata } from "next";
import { SectionHeading } from "@/components/section-heading";
import { DesignGallery } from "@/components/design-gallery";
import { CtaBand } from "@/components/cta-band";
import { designs } from "@/lib/designs";

export const metadata: Metadata = {
  title: "Designs — JAH Media",
  description: "Every email, SMS, and lifecycle design JAH Media has shipped, in one place.",
};

export default function DesignsPage() {
  return (
    <>
      <section className="container-page pt-20 pb-16 md:pt-28">
        <SectionHeading
          eyebrow="Designs"
          title="Every design, in one place."
          description="A running library of the emails, texts, and lifecycle assets we've written and designed — filter by type to browse."
        />
      </section>

      <section className="container-page pb-24 md:pb-32">
        <DesignGallery designs={designs} />
      </section>

      <CtaBand />
    </>
  );
}
