"use client";

import Link from "next/link";
import { motion } from "framer-motion";

export function Hero() {
  return (
    <section className="relative overflow-hidden pt-20 pb-24 md:pt-28 md:pb-32">
      <div className="noise-overlay" />
      <div
        className="pointer-events-none absolute -top-40 left-1/2 h-[520px] w-[820px] -translate-x-1/2 rounded-full opacity-[0.06] blur-3xl"
        style={{ background: "radial-gradient(circle, #121210, transparent 70%)" }}
      />

      <div className="container-page relative">
        <motion.div
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
          className="inline-flex items-center gap-2 rounded-full border border-border bg-surface px-4 py-1.5 text-xs font-medium tracking-wide text-muted uppercase"
        >
          <span className="h-1.5 w-1.5 rounded-full bg-accent" />
          Retention Marketing Agency
        </motion.div>

        <motion.h1
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.1, ease: [0.22, 1, 0.36, 1] }}
          className="font-display mt-7 max-w-4xl text-5xl leading-[1.03] font-bold text-balance sm:text-6xl md:text-7xl"
        >
          Turn one-time buyers into your{" "}
          <span className="text-accent">most repeatable</span> revenue.
        </motion.h1>

        <motion.p
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.2, ease: [0.22, 1, 0.36, 1] }}
          className="mt-7 max-w-xl text-lg leading-relaxed text-muted"
        >
          JAH Media is a retention marketing agency. We plan, write, and build the email &amp;
          SMS systems — flows, campaigns, and offers — that turn first purchases into repeat
          customers for ecommerce brands.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.7, delay: 0.3, ease: [0.22, 1, 0.36, 1] }}
          className="mt-10 flex flex-wrap items-center gap-4"
        >
          <Link
            href="/contact"
            className="inline-flex items-center justify-center rounded-full bg-accent px-7 py-3.5 text-sm font-semibold text-background transition-transform hover:scale-[1.03]"
          >
            Book a Free Retention Audit
          </Link>
          <Link
            href="/work"
            className="inline-flex items-center justify-center rounded-full border border-border px-7 py-3.5 text-sm font-semibold text-foreground transition-colors hover:border-foreground/40"
          >
            See Our Work
          </Link>
        </motion.div>
      </div>
    </section>
  );
}
