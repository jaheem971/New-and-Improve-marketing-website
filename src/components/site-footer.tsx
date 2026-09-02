import Link from "next/link";
import { navLinks, site } from "@/lib/site";

export function SiteFooter() {
  return (
    <footer className="border-t border-border bg-background">
      <div className="container-page py-16">
        <div className="grid gap-12 md:grid-cols-[1.4fr_1fr_1fr]">
          <div>
            <Link href="/" className="font-display text-xl font-bold tracking-tight">
              JAH<span className="text-accent">.</span>MEDIA
            </Link>
            <p className="mt-4 max-w-xs text-sm leading-relaxed text-muted">
              Retention marketing for ecommerce brands — email &amp; SMS systems built to keep
              customers coming back.
            </p>
          </div>

          <div>
            <p className="text-xs font-semibold tracking-widest text-muted uppercase">
              Site
            </p>
            <ul className="mt-4 space-y-3">
              {navLinks.map((link) => (
                <li key={link.href}>
                  <Link
                    href={link.href}
                    className="text-sm text-foreground/80 transition-colors hover:text-accent"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
              <li>
                <Link
                  href="/contact"
                  className="text-sm text-foreground/80 transition-colors hover:text-accent"
                >
                  Contact
                </Link>
              </li>
            </ul>
          </div>

          <div>
            <p className="text-xs font-semibold tracking-widest text-muted uppercase">
              Get in touch
            </p>
            <ul className="mt-4 space-y-3">
              <li>
                <a
                  href={`mailto:${site.email}`}
                  className="text-sm text-foreground/80 transition-colors hover:text-accent"
                >
                  {site.email}
                </a>
              </li>
              <li>
                <a
                  href={site.instagram}
                  target="_blank"
                  rel="noreferrer"
                  className="text-sm text-foreground/80 transition-colors hover:text-accent"
                >
                  Instagram
                </a>
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-16 flex flex-col gap-4 border-t border-border pt-8 text-xs text-muted sm:flex-row sm:items-center sm:justify-between">
          <p>© {new Date().getFullYear()} JAH Media. All rights reserved.</p>
          <p>Built by Jaheem Hodge.</p>
        </div>
      </div>
    </footer>
  );
}
