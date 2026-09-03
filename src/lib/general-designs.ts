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
  },
  {
    id: "fussy-1",
    title: "40,000 People Can't Be Wrong",
    brand: "Fussy",
    accent: "#c9702f",
  },
  {
    id: "starface-1",
    title: "They Said It Better Than We Could",
    brand: "Starface",
    accent: "#6ea3d9",
  },
  {
    id: "ilus-1",
    title: "Meet SeamLux™",
    brand: "ILUS",
    accent: "#8a5a34",
  },
];
