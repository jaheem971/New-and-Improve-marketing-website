export type ConceptPiece = {
  subject: string;
  flow: string;
  accent: string;
  image?: string;
  /** Short strategist bullets explaining the reasoning behind the piece */
  analysis: string[];
};

export type ConceptProject = {
  slug: string;
  brand: string;
  industry: string;
  summary: string;
  tags: string[];
  pieces: ConceptPiece[];
};

export const concepts: ConceptProject[] = [
  {
    slug: "asarai",
    brand: "ASARAI",
    industry: "Skincare / Concept",
    summary:
      "ASARAI is not a past or current client — these are self-initiated concept emails, built end to end (strategy, copy, and design) to show how I'd approach a skincare brand's welcome, cart-recovery, and social-proof sends.",
    tags: ["Self-Initiated Concept", "Strategy + Copywriting", "Design"],
    pieces: [
      {
        subject: "Less Cover-Up. More Skin.",
        flow: "Welcome Flow",
        accent: "#d9b32e",
        image: "/work/concepts/asarai-welcome-1.png",
        analysis: [
          "Leads with the emotional payoff (less cover-up) before the product, so the reader buys into the outcome first.",
          "The stats block reframes a detox mask as a measurable confidence tool, not just a product feature.",
          "Closes on the three-active ingredient breakdown to justify the price point with specifics, not adjectives.",
        ],
      },
      {
        subject: "Brighter Skin Starts Here",
        flow: "Welcome Flow",
        accent: "#a8402e",
        image: "/work/concepts/asarai-welcome-2.png",
        analysis: [
          "A how-to-use walkthrough builds usage confidence right after purchase — fewer refunds from 'I didn't know how to use it.'",
          "Progress-ring stats placed right after the instructions reinforce the habit at the exact moment someone decides whether to bother.",
          "Three clear steps turn a 15-minute mask into a simple ritual instead of a chore.",
        ],
      },
      {
        subject: "Enjoy 10% Off Your First Purchase",
        flow: "Abandoned Checkout",
        accent: "#d9b32e",
        image: "/work/concepts/asarai-cart-1.png",
        analysis: [
          "One low-friction CTA (Return to Cart) keeps the email focused on a single action instead of competing offers.",
          "The code sits above the fold so price hesitation gets resolved before any other objection.",
          "The stat trio re-sells the product benefit instead of just repeating the discount.",
        ],
      },
      {
        subject: "Your Skin's Ready For This.",
        flow: "Abandoned Checkout",
        accent: "#c9a876",
        image: "/work/concepts/asarai-cart-2.png",
        analysis: [
          "Naming the exact product and price removes the 'what was I even looking at' friction of a generic cart email.",
          "'You were onto something' nudges without guilt-tripping the shopper into coming back.",
          "Cross-sell blocks beneath the CTA give a second path to convert if the original item isn't the right fit.",
        ],
      },
      {
        subject: "Less Foundation. More Skin.",
        flow: "Social Proof",
        accent: "#a8402e",
        image: "/work/concepts/asarai-social-proof-1.png",
        analysis: [
          "Leads with the rating number because for a brand the reader doesn't know yet, trust has to come before the pitch.",
          "Specific, textured testimonials (pores, tightness, texture) read as unscripted — more persuasive than generic praise.",
          "Repeats the welcome offer at the bottom so the social proof becomes the bridge straight back to checkout.",
        ],
      },
    ],
  },
];
