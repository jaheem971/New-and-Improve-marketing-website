import Image from "next/image";
import type { EmailPiece } from "@/lib/case-studies";

export function EmailFrame({ piece }: { piece: EmailPiece }) {
  return (
    <div className="group relative flex flex-col overflow-hidden rounded-2xl border border-border bg-surface">
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
            <p className="font-display text-lg leading-tight font-medium text-balance">
              {piece.subject}
            </p>
            <p className="mt-3 text-[11px] tracking-widest text-muted uppercase">
              Screenshot coming soon
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
