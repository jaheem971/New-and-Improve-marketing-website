export type DesignCategory = "Email" | "SMS" | "Social" | "Landing Page";

export type Design = {
  id: string;
  title: string;
  client: string;
  category: DesignCategory;
  accent: string;
  /** Path under /public once the real file is added, e.g. "/designs/bitter-truth-welcome.png" */
  image?: string;
  /** Defaults to "9/16" (a typical email screenshot) if omitted */
  aspect?: string;
};

export const designs: Design[] = [
  {
    id: "bitter-truth-welcome-1",
    title: "Here's 20% Off Your First Subscription Order + A Free Mug",
    client: "Bitter Truth Coffee Co.",
    category: "Email",
    accent: "#d97b3f",
  },
  {
    id: "bitter-truth-welcome-2",
    title: "The People Behind Every Bag",
    client: "Bitter Truth Coffee Co.",
    category: "Email",
    accent: "#c9a879",
  },
  {
    id: "bitter-truth-cart-1",
    title: "Still Deciding? Here's 20% Off. The Bag Will Keep Either Way.",
    client: "Bitter Truth Coffee Co.",
    category: "Email",
    accent: "#8a5a2e",
  },
  {
    id: "bitter-truth-cart-2",
    title: "The Cart's Still Open.",
    client: "Bitter Truth Coffee Co.",
    category: "Email",
    accent: "#3d3128",
  },
  {
    id: "goodles-cart-1",
    title: "One Click Away From Love At First Bite",
    client: "Goodles",
    category: "Email",
    accent: "#e8312f",
  },
];
