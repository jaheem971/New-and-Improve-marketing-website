import { Hero } from "@/components/hero";
import { ClientStrip } from "@/components/client-strip";
import { ServicesGrid } from "@/components/services-grid";
import { WorkPreview } from "@/components/work-preview";
import { ProcessSteps } from "@/components/process-steps";
import { CtaBand } from "@/components/cta-band";

export default function Home() {
  return (
    <>
      <Hero />
      <ClientStrip />
      <ServicesGrid />
      <WorkPreview />
      <ProcessSteps />
      <CtaBand />
    </>
  );
}
