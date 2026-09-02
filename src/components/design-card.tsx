import Image from "next/image";
import type { Design } from "@/lib/designs";

export function DesignCard({ design }: { design: Design }) {
  return (
    <div className="group mb-4 break-inside-avoid overflow-hidden rounded-2xl border border-border bg-surface">
      <div
        className="relative w-full overflow-hidden"
        style={{ aspectRatio: design.aspect ?? "9 / 16" }}
      >
        {design.image ? (
          <Image
            src={design.image}
            alt={design.title}
            fill
            className="object-cover object-top transition-transform duration-500 group-hover:scale-[1.03]"
          />
        ) : (
          <div
            className="flex h-full w-full flex-col justify-end p-5"
            style={{
              background: `linear-gradient(160deg, ${design.accent}40 0%, #121210 75%)`,
            }}
          >
            <span
              className="mb-3 inline-block h-8 w-8 rounded-full"
              style={{ background: design.accent }}
            />
            <p className="font-display text-lg leading-tight font-medium text-balance text-background">
              {design.title}
            </p>
            <p className="mt-3 text-[11px] tracking-widest text-background/60 uppercase">
              Screenshot coming soon
            </p>
          </div>
        )}
      </div>
      <div className="flex items-center justify-between gap-3 px-4 py-3">
        <span className="truncate text-sm font-medium text-foreground/85">{design.client}</span>
        <span className="shrink-0 rounded-full border border-border px-2.5 py-1 text-[11px] text-muted">
          {design.category}
        </span>
      </div>
    </div>
  );
}
