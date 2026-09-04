export type EmailPiece = {
  subject: string;
  flow: string;
  /** Path under /public once the real screenshot is added, e.g. "/work/bitter-truth/welcome.png" */
  image?: string;
  accent: string;
};

export type CaseStudy = {
  slug: string;
  client: string;
  industry: string;
  summary: string;
  services: string[];
  accent: string;
  bg: string;
  pieces: EmailPiece[];
};

export const caseStudies: CaseStudy[] = [
  {
    slug: "bitter-truth-coffee",
    client: "Bitter Truth Coffee Co.",
    industry: "Coffee / Subscription",
    summary:
      "A welcome series and abandoned-checkout flow built to turn first-time visitors into subscribers — written and designed end to end, from the founder-voiced story emails to the roast picker in the final cart-recovery send.",
    services: ["Email Flow Strategy", "Klaviyo Design & Build", "Copywriting"],
    accent: "#d97b3f",
    bg: "#171310",
    pieces: [
      {
        subject: "Here's 20% Off Your First Subscription Order + A Free Mug",
        flow: "Welcome Flow",
        accent: "#d97b3f",
        image: "/work/bitter-truth-coffee/welcome-1.png",
      },
      {
        subject: "The People Behind Every Bag",
        flow: "Welcome Flow",
        accent: "#c9a879",
        image: "/work/bitter-truth-coffee/welcome-2.png",
      },
      {
        subject: "Still Deciding? Here's 20% Off. The Bag Will Keep Either Way.",
        flow: "Abandoned Checkout",
        accent: "#8a5a2e",
        image: "/work/bitter-truth-coffee/cart-1.png",
      },
      {
        subject: "The Cart's Still Open.",
        flow: "Abandoned Checkout",
        accent: "#3d3128",
        image: "/work/bitter-truth-coffee/cart-2.png",
      },
    ],
  },
];
