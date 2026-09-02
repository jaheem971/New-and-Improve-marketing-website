"use client";

import { useState } from "react";
import { site } from "@/lib/site";

const revenueRanges = [
  "Under $50k/mo",
  "$50k–$100k/mo",
  "$100k–$500k/mo",
  "$500k+/mo",
];

export function ContactForm() {
  const [submitted, setSubmitted] = useState(false);

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const form = new FormData(e.currentTarget);
    const name = String(form.get("name") ?? "");
    const brand = String(form.get("brand") ?? "");
    const website = String(form.get("website") ?? "");
    const revenue = String(form.get("revenue") ?? "");
    const email = String(form.get("email") ?? "");
    const message = String(form.get("message") ?? "");

    const subject = `Retention audit request — ${brand || name}`;
    const body = [
      `Name: ${name}`,
      `Brand: ${brand}`,
      `Website: ${website}`,
      `Monthly revenue: ${revenue}`,
      `Email: ${email}`,
      "",
      message,
    ].join("\n");

    window.location.href = `mailto:${site.email}?subject=${encodeURIComponent(
      subject
    )}&body=${encodeURIComponent(body)}`;
    setSubmitted(true);
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-5">
      <div className="grid gap-5 sm:grid-cols-2">
        <Field label="Your name" name="name" required />
        <Field label="Email" name="email" type="email" required />
      </div>
      <div className="grid gap-5 sm:grid-cols-2">
        <Field label="Brand name" name="brand" required />
        <Field label="Website / Shopify URL" name="website" />
      </div>

      <label className="block">
        <span className="text-sm font-medium text-foreground/85">Monthly revenue</span>
        <select
          name="revenue"
          className="mt-2 w-full rounded-xl border border-border bg-surface px-4 py-3 text-sm text-foreground focus:border-accent focus:outline-none"
        >
          {revenueRanges.map((r) => (
            <option key={r} value={r}>
              {r}
            </option>
          ))}
        </select>
      </label>

      <label className="block">
        <span className="text-sm font-medium text-foreground/85">
          What&apos;s going on with retention right now?
        </span>
        <textarea
          name="message"
          rows={4}
          className="mt-2 w-full resize-none rounded-xl border border-border bg-surface px-4 py-3 text-sm text-foreground focus:border-accent focus:outline-none"
          placeholder="Tell me about your current flows, list size, or what's not working."
        />
      </label>

      <button
        type="submit"
        className="inline-flex w-full items-center justify-center rounded-full bg-accent px-7 py-3.5 text-sm font-semibold text-background transition-transform hover:scale-[1.02] sm:w-auto"
      >
        Send it over
      </button>

      {submitted ? (
        <p className="text-sm text-muted">
          Opening your email client — if nothing happened, email me directly at{" "}
          <a href={`mailto:${site.email}`} className="text-accent">
            {site.email}
          </a>
          .
        </p>
      ) : null}
    </form>
  );
}

function Field({
  label,
  name,
  type = "text",
  required,
}: {
  label: string;
  name: string;
  type?: string;
  required?: boolean;
}) {
  return (
    <label className="block">
      <span className="text-sm font-medium text-foreground/85">{label}</span>
      <input
        name={name}
        type={type}
        required={required}
        className="mt-2 w-full rounded-xl border border-border bg-surface px-4 py-3 text-sm text-foreground focus:border-accent focus:outline-none"
      />
    </label>
  );
}
