"use client";

import Image from "next/image";
import { X } from "lucide-react";
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
        className="relative flex max-h-[88vh] w-full max-w-md flex-col overflow-hidden rounded-2xl bg-surface shadow-2xl"
      >
        <div className="relative h-[70vh] w-full">
          {item.image ? (
            <Image src={item.image} alt={item.title} fill className="object-contain" />
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

        <div className="border-t border-border px-6 py-4">
          {item.subtitle ? (
            <p className="text-xs font-semibold tracking-widest text-muted uppercase">
              {item.subtitle}
            </p>
          ) : null}
          <p className="font-display mt-1 text-base font-bold text-balance">{item.title}</p>
        </div>
      </div>
    </div>
  );
}
