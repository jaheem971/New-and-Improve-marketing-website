export const services = [
  {
    number: "01",
    title: "Email Marketing",
    description:
      "Full Klaviyo build-outs — welcome series, abandoned cart & checkout, post-purchase, win-back, and weekly campaigns written to sound like your brand, not a template.",
  },
  {
    number: "02",
    title: "SMS Marketing",
    description:
      "List growth and text campaigns that respect the inbox — timely, high-signal sends that turn a phone number into a repeat customer.",
  },
  {
    number: "03",
    title: "Lifecycle Strategy",
    description:
      "Segmentation, popups, and offer strategy mapped to how your customers actually buy — so every flow has a job to do.",
  },
  {
    number: "04",
    title: "Design & Copy",
    description:
      "On-brand templates and conversion copy built together, not handed off — every email is designed to be read and written to be clicked.",
  },
];

export const engagementTiers = [
  {
    tag: "DIAGNOSE",
    icon: "search" as const,
    title: "Retention Audit",
    tagline: "See exactly what's working, what's leaking revenue, and what to fix first.",
    bestFor:
      "Brands already running email & SMS who aren't sure where the real opportunity is.",
    includes: [
      "Full flow & campaign review",
      "Prioritized fix list, ranked by revenue impact",
      "A clear action plan you can hand to any team",
    ],
    priceLabel: "Book a call for pricing",
    highlight: false,
  },
  {
    tag: "BUILD",
    icon: "layers" as const,
    title: "Flow Build",
    tagline: "Get the email & SMS foundation your store should already have.",
    bestFor: "Brands with missing, outdated, or underbuilt automation.",
    includes: [
      "Welcome, abandoned cart/checkout & post-purchase flows",
      "Full flow strategy & architecture",
      "Copy + design, built and QA'd inside Klaviyo",
    ],
    priceLabel: "Book a call for pricing",
    highlight: true,
  },
  {
    tag: "OPERATE",
    icon: "calendar" as const,
    title: "Lite Management",
    tagline: "Keep retention moving without handing over the whole channel.",
    bestFor: "Brands with a solid foundation that need consistent execution.",
    includes: [
      "Monthly campaign planning & execution",
      "List & segment management",
      "Monthly reporting & performance reviews",
    ],
    priceLabel: "Book a call for pricing",
    highlight: false,
  },
  {
    tag: "OWN",
    icon: "crown" as const,
    title: "Full Management",
    tagline: "Hand retention to an expert and get it off your plate completely.",
    bestFor: "Brands ready to stop managing email & SMS internally.",
    includes: [
      "Full email + SMS strategy & management",
      "Ongoing segmentation & testing",
      "Lifecycle oversight built around growth",
    ],
    priceLabel: "Book a call for pricing",
    highlight: true,
  },
];

export const process = [
  {
    number: "01",
    title: "Audit",
    description:
      "We dig into your current flows, campaigns, and list health to find exactly where revenue is leaking.",
  },
  {
    number: "02",
    title: "Strategy",
    description:
      "We map the flows, segments, and offers your brand actually needs — no generic templates, no guesswork.",
  },
  {
    number: "03",
    title: "Build",
    description:
      "We write and design every email and text ourselves, on-brand and ready to send inside Klaviyo.",
  },
  {
    number: "04",
    title: "Optimize",
    description:
      "We test subject lines, offers, and timing every month so retention revenue keeps climbing.",
  },
];
