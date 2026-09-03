"use client";

import Image from "next/image";
import { Maximize2 } from "lucide-react";
import type { GeneralDesign } from "@/lib/general-designs";
import { useLightbox } from "@/components/lightbox-provider";

export function GeneralDesignsGrid({ designs }: { designs: GeneralDesign[] }) {
  const openLightbox = useLightbox();

  return (
    <div className="columns-1 gap-4 sm:columns-2 lg:columns-4">
      {designs.map((design) => (
        <button
          type="button"
          key={design.id}
          onClick={() =>
            openLightbox({
              title: design.title,
              subtitle: design.brand,
              image: design.image,
              accent: design.accent,
            })
          }
          className="group mb-4 block w-full break-inside-avoid overflow-hidden rounded-2xl border border-border bg-surface text-left"
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

            <span className="absolute top-3 right-3 flex h-8 w-8 items-center justify-center rounded-full bg-background/90 opacity-0 shadow-sm transition-opacity duration-200 group-hover:opacity-100">
              <Maximize2 className="h-3.5 w-3.5 text-foreground" strokeWidth={2} />
            </span>
          </div>
          <div className="px-4 py-3">
            <span className="text-sm font-medium text-foreground/85">{design.brand}</span>
          </div>
        </button>
      ))}
    </div>
  );
}
