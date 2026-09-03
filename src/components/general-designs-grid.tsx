import Image from "next/image";
import type { GeneralDesign } from "@/lib/general-designs";

export function GeneralDesignsGrid({ designs }: { designs: GeneralDesign[] }) {
  return (
    <div className="columns-1 gap-4 sm:columns-2 lg:columns-4">
      {designs.map((design) => (
        <div
          key={design.id}
          className="group mb-4 break-inside-avoid overflow-hidden rounded-2xl border border-border bg-surface"
        >
          <div className="relative aspect-[9/16] w-full overflow-hidden">
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
          <div className="px-4 py-3">
            <span className="text-sm font-medium text-foreground/85">{design.brand}</span>
          </div>
        </div>
      ))}
    </div>
  );
}
