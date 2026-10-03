"use client";

import { Lightbulb, X, ZoomIn, ZoomOut } from "lucide-react";
import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from "react";

type LightboxItem = {
  title: string;
  subtitle?: string;
  image?: string;
  accent: string;
  /** Optional strategist notes shown alongside the image */
  analysis?: string[];
};

const LightboxContext = createContext<((item: LightboxItem) => void) | null>(null);

export function useLightbox() {
  const open = useContext(LightboxContext);
  if (!open) throw new Error("useLightbox must be used within LightboxProvider");
  return open;
}

export function LightboxProvider({ children }: { children: ReactNode }) {
  const [item, setItem] = useState<LightboxItem | null>(null);
  const close = useCallback(() => setItem(null), []);

  useEffect(() => {
    if (!item) return;
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") close();
    };
    window.addEventListener("keydown", onKey);
    return () => {
      document.body.style.overflow = previousOverflow;
      window.removeEventListener("keydown", onKey);
    };
  }, [item, close]);

  return (
    <LightboxContext.Provider value={setItem}>
      {children}
      {item ? <LightboxModal item={item} onClose={close} /> : null}
    </LightboxContext.Provider>
  );
}

function LightboxModal({ item, onClose }: { item: LightboxItem; onClose: () => void }) {
  const [zoomed, setZoomed] = useState(false);
  const hasAnalysis = !!item.analysis?.length;

  const imagePane = (
    <div className={hasAnalysis ? "relative sm:w-[55%] sm:shrink-0" : "relative"}>
      <div
        className={`w-full overflow-auto bg-surface-2 ${hasAnalysis ? "h-[38vh] sm:h-[70vh]" : "h-[70vh]"} ${
          item.image ? (zoomed ? "cursor-zoom-out" : "cursor-zoom-in") : ""
        }`}
        onClick={(e) => {
          e.stopPropagation();
          if (item.image) setZoomed((z) => !z);
        }}
      >
        {item.image ? (
          // eslint-disable-next-line @next/next/no-img-element -- zoom needs a runtime-controlled width next/image's fill/fixed sizing can't express
          <img
            src={item.image}
            alt={item.title}
            className={`block transition-[width] duration-300 ${
              zoomed ? "w-[230%] max-w-none" : "w-full"
            }`}
          />
        ) : (
          <div
            className="flex h-full w-full flex-col justify-end p-8"
            style={{
              background: `linear-gradient(160deg, ${item.accent}40 0%, #121210 75%)`,
            }}
          >
            <span
              className="mb-4 inline-block h-10 w-10 rounded-full"
              style={{ background: item.accent }}
            />
            <p className="font-display text-2xl leading-tight font-medium text-balance text-background">
              {item.title}
            </p>
            <p className="mt-4 text-xs tracking-widest text-background/60 uppercase">
              Screenshot coming soon
            </p>
          </div>
        )}
      </div>

      {item.image ? (
        <span className="pointer-events-none absolute top-3 left-3 inline-flex h-9 w-9 items-center justify-center rounded-full bg-background/90 shadow-sm">
          {zoomed ? (
            <ZoomOut className="h-4 w-4 text-foreground" strokeWidth={2} />
          ) : (
            <ZoomIn className="h-4 w-4 text-foreground" strokeWidth={2} />
          )}
        </span>
      ) : null}
    </div>
  );

  return (
    <div
      role="dialog"
      aria-modal="true"
      aria-label={item.title}
      onClick={onClose}
      className="fixed inset-0 z-[100] flex items-center justify-center bg-foreground/80 p-4 backdrop-blur-sm sm:p-8"
    >
      <button
        type="button"
        onClick={onClose}
        aria-label="Close"
        className="fixed top-4 right-4 z-10 flex h-11 w-11 items-center justify-center rounded-full bg-background text-foreground transition-transform hover:scale-105 sm:top-6 sm:right-6"
      >
        <X className="h-5 w-5" strokeWidth={2} />
      </button>

      <div
        onClick={(e) => e.stopPropagation()}
        className={`relative flex max-h-[88vh] w-full flex-col overflow-hidden rounded-2xl bg-surface shadow-2xl ${
          hasAnalysis ? "max-w-3xl sm:flex-row" : "max-w-md"
        }`}
      >
        {imagePane}

        {hasAnalysis ? (
          <div className="flex flex-1 flex-col overflow-y-auto border-t border-border p-6 sm:w-[45%] sm:border-t-0 sm:border-l">
            {item.subtitle ? (
              <p className="text-xs font-semibold tracking-widest text-muted uppercase">
                {item.subtitle}
              </p>
            ) : null}
            <p className="font-display mt-1 text-lg font-bold text-balance">{item.title}</p>

            <div className="mt-6 flex items-center gap-2 text-accent">
              <Lightbulb className="h-4 w-4" strokeWidth={2} />
              <p className="text-xs font-semibold tracking-widest uppercase">
                Why this works
              </p>
            </div>
            <ul className="mt-3 space-y-3">
              {item.analysis!.map((note) => (
                <li key={note} className="flex items-start gap-2.5 text-sm leading-relaxed text-foreground/85">
                  <span className="mt-2 h-1 w-1 shrink-0 rounded-full bg-accent" />
                  {note}
                </li>
              ))}
            </ul>
          </div>
        ) : (
          <div className="border-t border-border px-6 py-4">
            {item.subtitle ? (
              <p className="text-xs font-semibold tracking-widest text-muted uppercase">
                {item.subtitle}
              </p>
            ) : null}
            <p className="font-display mt-1 text-base font-bold text-balance">{item.title}</p>
          </div>
        )}
      </div>
    </div>
  );
}
