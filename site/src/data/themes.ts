export type Palette = {
  bg: string;
  bg_alt: string;
  fg: string;
  fg_gutter: string;
  comment: string;
  red: string;
  green: string;
  yellow: string;
  blue: string;
  magenta: string;
  cyan: string;
  accent: string;
  border: string;
  error: string;
  warn: string;
};
export type Theme = {
  id: number;
  name: string;
  tagline: string;
  day: Palette;
  night: Palette;
};

export const themes: Theme[] = [
  {
    id: 1,
    name: "Minimal",
    tagline: "Quiet paper-and-ink editing, zero noise",
    day: {
      bg: "#fbf8f3", bg_alt: "#efe9df", fg: "#3a3733", fg_gutter: "#b8b0a2", comment: "#a39b8d", red: "#a8423e", green: "#4c7a4f", yellow: "#9a7330", blue: "#3f6b91", magenta: "#7d5387", cyan: "#417a77", accent: "#8a6d3b", border: "#ddd5c8", error: "#a8423e", warn: "#9a7330"
    },
    night: {
      bg: "#1d1e20", bg_alt: "#26282b", fg: "#d4d2cd", fg_gutter: "#5c5e63", comment: "#6f7176", red: "#d98d84", green: "#9cc49b", yellow: "#d9bc7f", blue: "#8ab4d8", magenta: "#c09ac9", cyan: "#8ac9c4", accent: "#c9a86a", border: "#3a3d42", error: "#d98d84", warn: "#d9bc7f"
    },
  },
  {
    id: 2,
    name: "Tokyo Neon",
    tagline: "Electric blues from a neon cityscape",
    day: {
      bg: "#f5f7fc", bg_alt: "#e6ebf5", fg: "#35416f", fg_gutter: "#9aa8c7", comment: "#8f9fbe", red: "#db5c7c", green: "#309c78", yellow: "#b07e00", blue: "#376bd0", magenta: "#9a5ad0", cyan: "#2e82aa", accent: "#7c5cff", border: "#bcc8e4", error: "#db5c7c", warn: "#b07e00"
    },
    night: {
      bg: "#161823", bg_alt: "#1e2130", fg: "#c0caf5", fg_gutter: "#3b4261", comment: "#565f89", red: "#f55c8a", green: "#2fc98a", yellow: "#e5b564", blue: "#6aa8ff", magenta: "#c792ea", cyan: "#34cdc9", accent: "#bb9af7", border: "#2f3352", error: "#f55c8a", warn: "#e5b564"
    },
  },
  {
    id: 3,
    name: "Cyberpunk",
    tagline: "High-voltage magenta and acid cyan",
    day: {
      bg: "#fff7fa", bg_alt: "#ffe3ee", fg: "#4a1033", fg_gutter: "#c98aa8", comment: "#b56a8a", red: "#e0145e", green: "#00a86b", yellow: "#d98e00", blue: "#0077c2", magenta: "#d4008f", cyan: "#00b3b3", accent: "#ff2d78", border: "#f5b8d0", error: "#e0145e", warn: "#d98e00"
    },
    night: {
      bg: "#0b0714", bg_alt: "#170d26", fg: "#f2e9ff", fg_gutter: "#5a3a78", comment: "#7a5c9e", red: "#ff2e63", green: "#08f7fe", yellow: "#f7d308", blue: "#059aff", magenta: "#ff00ff", cyan: "#00fff5", accent: "#ff2e63", border: "#3d1f5c", error: "#ff2e63", warn: "#f7d308"
    },
  },
  {
    id: 4,
    name: "Nord Ice",
    tagline: "Arctic calm, polar night blues",
    day: {
      bg: "#eceff4", bg_alt: "#e5e9f0", fg: "#2e3440", fg_gutter: "#9ba5b5", comment: "#a7b0c0", red: "#bf616a", green: "#a3be8c", yellow: "#ebcb8b", blue: "#5e81ac", magenta: "#b48ead", cyan: "#88c0d0", accent: "#5e81ac", border: "#c8d0dd", error: "#bf616a", warn: "#d08770"
    },
    night: {
      bg: "#2e3440", bg_alt: "#3b4252", fg: "#d8dee9", fg_gutter: "#616e88", comment: "#616e88", red: "#bf616a", green: "#a3be8c", yellow: "#ebcb8b", blue: "#81a1c1", magenta: "#b48ead", cyan: "#88c0d0", accent: "#88c0d0", border: "#434c5e", error: "#bf616a", warn: "#ebcb8b"
    },
  },
  {
    id: 5,
    name: "Gruvbox Warm",
    tagline: "Retro groove, warm earth tones",
    day: {
      bg: "#f2e5c4", bg_alt: "#ebdbb2", fg: "#3c3836", fg_gutter: "#a89984", comment: "#928374", red: "#cc241d", green: "#98971a", yellow: "#d79921", blue: "#458588", magenta: "#b16286", cyan: "#689d6a", accent: "#af5f00", border: "#d5c4a1", error: "#cc241d", warn: "#d79921"
    },
    night: {
      bg: "#1d2021", bg_alt: "#282828", fg: "#ebdbb2", fg_gutter: "#665c54", comment: "#928374", red: "#fb4934", green: "#b8bb26", yellow: "#fabd2f", blue: "#83a598", magenta: "#d3869b", cyan: "#8ec07c", accent: "#fe8019", border: "#3c3836", error: "#fb4934", warn: "#fabd2f"
    },
  },
  {
    id: 6,
    name: "Monochrome",
    tagline: "Grayscale focus, one cold accent",
    day: {
      bg: "#fafafa", bg_alt: "#ededed", fg: "#1a1a1a", fg_gutter: "#a8a8a8", comment: "#9a9a9a", red: "#6e6e6e", green: "#4f4f4f", yellow: "#8a8a8a", blue: "#2f4a68", magenta: "#5a5a5a", cyan: "#3f5a6e", accent: "#2f4a68", border: "#cfcfcf", error: "#1a1a1a", warn: "#6e6e6e"
    },
    night: {
      bg: "#111111", bg_alt: "#1c1c1c", fg: "#e2e2e2", fg_gutter: "#585858", comment: "#666666", red: "#9e9e9e", green: "#b0b0b0", yellow: "#c8c8c8", blue: "#7fa5c9", magenta: "#8a8a8a", cyan: "#93b3bf", accent: "#7fa5c9", border: "#333333", error: "#ffffff", warn: "#c8c8c8"
    },
  },
  {
    id: 7,
    name: "Matrix",
    tagline: "Green phosphor terminal dreams",
    day: {
      bg: "#eef7ee", bg_alt: "#dcf0dc", fg: "#0c3a14", fg_gutter: "#7fae87", comment: "#88b890", red: "#7a4a00", green: "#1d7a2c", yellow: "#6b6b00", blue: "#22688a", magenta: "#5a2d7a", cyan: "#177a6a", accent: "#1d7a2c", border: "#b5dcb9", error: "#a03030", warn: "#6b6b00"
    },
    night: {
      bg: "#030a03", bg_alt: "#08140a", fg: "#33dd55", fg_gutter: "#1a5c28", comment: "#1f8a35", red: "#e05555", green: "#33ff66", yellow: "#d7d733", blue: "#33b1ff", magenta: "#b04ae0", cyan: "#28e0c8", accent: "#33ff66", border: "#14401c", error: "#e05555", warn: "#d7d733"
    },
  },
  {
    id: 8,
    name: "Pastel",
    tagline: "Soft candy colors, easy on the eyes",
    day: {
      bg: "#f7f2f5", bg_alt: "#ede4ec", fg: "#575268", fg_gutter: "#b3aabf", comment: "#a49bb0", red: "#d8576b", green: "#4da36e", yellow: "#d9a441", blue: "#5e7fd4", magenta: "#b06fc9", cyan: "#4aa8b8", accent: "#c26fd0", border: "#d8cede", error: "#d8576b", warn: "#d9a441"
    },
    night: {
      bg: "#201e2b", bg_alt: "#2a2739", fg: "#dcd4e8", fg_gutter: "#5c5672", comment: "#7a7393", red: "#f5a0ab", green: "#a3d8b0", yellow: "#f2d5a0", blue: "#a5b8f0", magenta: "#d8b0f0", cyan: "#98dae2", accent: "#cba6f7", border: "#3b3651", error: "#f5a0ab", warn: "#f2d5a0"
    },
  },
  {
    id: 9,
    name: "Material",
    tagline: "Design-system blues, teal and amber",
    day: {
      bg: "#eaedf2", bg_alt: "#dde2ea", fg: "#25303b", fg_gutter: "#93a1b0", comment: "#8296a8", red: "#c52f57", green: "#1a9d5c", yellow: "#b87e0a", blue: "#1f77c8", magenta: "#8e3fc0", cyan: "#0091a8", accent: "#0091a8", border: "#bcc9d6", error: "#c52f57", warn: "#b87e0a"
    },
    night: {
      bg: "#19212b", bg_alt: "#212b38", fg: "#d9e4ee", fg_gutter: "#4d6275", comment: "#5c7387", red: "#f07178", green: "#c3e88d", yellow: "#ffcb6b", blue: "#82aaff", magenta: "#c792ea", cyan: "#89ddff", accent: "#89ddff", border: "#2e4054", error: "#f07178", warn: "#ffcb6b"
    },
  },
  {
    id: 10,
    name: "Futuristic",
    tagline: "Deep-space HUD, hologram teal",
    day: {
      bg: "#f2f4fb", bg_alt: "#e4e8f7", fg: "#2c2f52", fg_gutter: "#9aa2c8", comment: "#8d95bd", red: "#d43a6a", green: "#12a594", yellow: "#c98a2b", blue: "#4457d6", magenta: "#8a4fd0", cyan: "#0fb8d4", accent: "#4457d6", border: "#c4cce8", error: "#d43a6a", warn: "#c98a2b"
    },
    night: {
      bg: "#0a0c1c", bg_alt: "#12152b", fg: "#dce2ff", fg_gutter: "#3d4470", comment: "#525a8c", red: "#ff5c8a", green: "#1de9b6", yellow: "#ffd166", blue: "#5c7cff", magenta: "#b45cff", cyan: "#00e5ff", accent: "#00e5ff", border: "#232a52", error: "#ff5c8a", warn: "#ffd166"
    },
  },
];
