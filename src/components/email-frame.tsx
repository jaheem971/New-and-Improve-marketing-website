"use client";

import Image from "next/image";
import { Maximize2 } from "lucide-react";
import type { EmailPiece } from "@/lib/case-studies";
import { useLightbox } from "@/components/lightbox-provider";

export function EmailFrame({ piece, client }: { piece: EmailPiece; client?: string }) {
  const openLightbox = useLightbox();

  return (
    <button
      type="button"
      onClick={() =>
        openLightbox({
          title: piece.subject,
          subtitle: client ? `${client} — ${piece.flow}` : piece.flow,
          image: piece.image,
          accent: piece.accent,
        })
      }
      className="group relative flex w-full flex-col overflow-hidden rounded-2xl border border-border bg-surface text-left"
    >
      <div className="flex items-center gap-1.5 border-b border-border bg-surface-2 px-3 py-2.5">
        <span className="h-2 w-2 rounded-full bg-foreground/20" />
        <span className="h-2 w-2 rounded-full bg-foreground/20" />
        <span className="h-2 w-2 rounded-full bg-foreground/20" />
        <span className="ml-2 truncate text-[11px] text-muted">{piece.flow}</span>
      </div>

      <div className="relative aspect-[9/16] w-full overflow-hidden">
        {piece.image ? (
          <Image
            src={piece.image}
            alt={piece.subject}
            fill
            className="object-cover object-top transition-transform duration-500 group-hover:scale-[1.03]"
          />
        ) : (
          <div
            className="flex h-full w-full flex-col justify-end p-5"
            style={{
              background: `linear-gradient(160deg, ${piece.accent}40 0%, #121210 75%)`,
            }}
          >
            <span
              className="mb-3 inline-block h-8 w-8 rounded-full"
              style={{ background: piece.accent }}
            />
            <p className="font-display text-lg leading-tight font-medium text-balance text-background">
              {piece.subject}
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
    </button>
  );
}
