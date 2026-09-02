import Link from "next/link";
import { Reveal } from "@/components/reveal";

export function CtaBand() {
  return (
    <section className="border-t border-border">
      <div className="container-page py-24 text-center md:py-32">
        <Reveal>
          <p className="text-xs font-semibold tracking-widest text-accent uppercase">
            Let&apos;s talk
          </p>
          <h2 className="font-display mx-auto mt-4 max-w-2xl text-4xl leading-[1.05] font-bold text-balance sm:text-5xl">
            Ready to make your list your best revenue channel?
          </h2>
          <p className="mx-auto mt-5 max-w-md text-muted">
            Book a free retention audit — we&apos;ll show you exactly where your flows are
            leaving money on the table.
          </p>
          <Link
            href="/contact"
            className="mt-9 inline-flex items-center justify-center rounded-full bg-accent px-8 py-4 text-sm font-semibold text-background transition-transform hover:scale-[1.03]"
          >
            Book a Free Retention Audit
          </Link>
        </Reveal>
      </div>
    </section>
  );
}
