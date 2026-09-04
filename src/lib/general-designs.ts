export type GeneralDesign = {
  id: string;
  title: string;
  brand: string;
  accent: string;
  /** Path under /public once the real file is added, e.g. "/work/general/everyday-dose.png" */
  image?: string;
};

export const generalDesigns: GeneralDesign[] = [
  {
    id: "everyday-dose-1",
    title: "Don't Quit Coffee. Just Make It A Better One.",
    brand: "Everyday Dose",
    accent: "#c9b8e8",
    image: "/work/general/everyday-dose-1.png",
  },
  {
    id: "fussy-1",
    title: "40,000 People Can't Be Wrong",
    brand: "Fussy",
    accent: "#c9702f",
    image: "/work/general/fussy-1.png",
  },
  {
    id: "starface-1",
    title: "They Said It Better Than We Could",
    brand: "Starface",
    accent: "#6ea3d9",
    image: "/work/general/starface-1.png",
  },
  {
    id: "hears-1",
    title: "Hear The Moment. Not The Damage.",
    brand: "Hears",
    accent: "#3d5a80",
    image: "/work/general/hears-1.png",
  },
  {
    id: "goodles-1",
    title: "One Click Away From Love At First Bite",
    brand: "Goodles",
    accent: "#e8312f",
  },
];
