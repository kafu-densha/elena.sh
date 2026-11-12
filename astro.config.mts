import fs from "node:fs";
import path from "node:path";
import { defineConfig, fontProviders } from "astro/config";
import svelte from "@astrojs/svelte";
import tailwindcss from "@tailwindcss/vite";
import { vitePreprocess } from "@astrojs/svelte";

import type { FontData } from "astro:assets";

interface FontDataFilter {
  weights: string[];
  styles: string[];
  subsets: string[];
}

function generateVariants(font: string, filter: FontDataFilter) {
  let variants = [];
  const fontDir = "./node_modules/@fontsource/" + font + "/files";

  const files = fs.readdirSync(fontDir);

  const escapedFontName = font.replace(/[-\/\\^$*+?.()|[\]{}]/g, "\\$&");
  const fontRegex = new RegExp(
    `^${escapedFontName}-([a-z0-9-]+)-(\\d+)-(normal|italic)\\.woff2$`,
  );

  const variantMap = new Map<string, Required<FontData>>();

  for (const file of files) {
    const match = file.match(fontRegex);
    if (!match) continue;

    const [_, subset, weight, style, ext] = match;

    const key = `${subset}-${weight}-${style}`;

    if (!variantMap.has(key)) {
      variantMap.set(key, {
        weight,
        style,
        subset,
        src: [],
      });
    }

    variantMap
      .get(key)
      ?.src.push({ url: path.join(fontDir, file), format: "woff2" });
  }

  variants = Array.from(variantMap.values());

  variants = variants.filter(
    (variant) =>
      filter.weights.includes(variant.weight) &&
      filter.styles.includes(variant.style) &&
      filter.subsets.includes(variant.subset),
  );

  return variants;
}

// https://astro.build/config
export default defineConfig({
  site: "https://elena.sh",

  integrations: [
    svelte({
      preprocess: vitePreprocess(),
    }),
  ],

  vite: {
    plugins: [tailwindcss()],
  },

  image: {
    layout: "constrained",
    responsiveStyles: false,
  },

  fonts: [
    {
      provider: fontProviders.local(),
      name: "Iosevka Charon",
      cssVariable: "--font-iosevka",
      options: {
        //@ts-ignore
        variants: generateVariants("iosevka-charon", {
          weights: ["400", "500", "700"],
          styles: ["normal"],
          subsets: ["latin"],
        }),
      },
    },
    {
      provider: fontProviders.local(),
      name: "Iosevka Charon Mono",
      cssVariable: "--font-iosevka-mono",

      options: {
        //@ts-ignore
        variants: generateVariants("iosevka-charon-mono", {
          weights: ["400", "500", "700"],
          styles: ["normal"],
          subsets: ["latin"],
        }),
      },
    },
  ],
});
