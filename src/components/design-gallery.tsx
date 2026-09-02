"use client";

import { useMemo, useState } from "react";
import { DesignCard } from "@/components/design-card";
import type { Design, DesignCategory } from "@/lib/designs";

export function DesignGallery({ designs }: { designs: Design[] }) {
  const categories = useMemo(() => {
    const set = new Set<DesignCategory>(designs.map((d) => d.category));
    return Array.from(set);
  }, [designs]);

  const [active, setActive] = useState<DesignCategory | "All">("All");

  const filtered = active === "All" ? designs : designs.filter((d) => d.category === active);

  return (
    <div>
      <div className="flex flex-wrap gap-2">
        {(["All", ...categories] as const).map((category) => (
          <button
            key={category}
            type="button"
            onClick={() => setActive(category)}
            className={`rounded-full border px-4 py-2 text-sm font-medium transition-colors ${
              active === category
                ? "border-accent bg-accent text-background"
                : "border-border text-foreground/80 hover:border-foreground/40"
            }`}
          >
            {category}
          </button>
        ))}
      </div>

      {filtered.length > 0 ? (
        <div className="mt-10 columns-1 gap-4 sm:columns-2 lg:columns-3">
          {filtered.map((design) => (
            <DesignCard key={design.id} design={design} />
          ))}
        </div>
      ) : (
        <p className="mt-10 text-sm text-muted">No designs in this category yet.</p>
      )}
    </div>
  );
}
