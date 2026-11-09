//@ts-check
import fs from "node:fs";
import path from "node:path";
import { defineConfig, fontProviders } from "astro/config";

import svelte from "@astrojs/svelte";
import tailwindcss from "@tailwindcss/vite";

//@ts-ignore
function generateVariants(font) {
  let variants = [];
  const fontDir = "./node_modules/@fontsource/" + font + "/files";

  const files = fs.readdirSync(fontDir);

  const escapedFontName = font.replace(/[-\/\\^$*+?.()|[\]{}]/g, "\\$&");
  const fontRegex = new RegExp(
    `^${escapedFontName}-([a-z0-9-]+)-(\\d+)-(normal|italic)\\.(woff2|woff)$`,
  );

  const variantMap = new Map();

  for (const file of files) {
    const match = file.match(fontRegex);
    if (!match) continue;

    const [_, subset, weightStr, style, ext] = match;
    const weight = parseInt(weightStr, 10);

    const key = `${subset}-${weight}-${style}`;

    if (!variantMap.has(key)) {
      variantMap.set(key, {
        weight,
        style,
        subset,
        src: [],
      });
    }

    variantMap.get(key).src.push(path.join(fontDir, file));
  }

  variants = Array.from(variantMap.values());

  return variants;
}

// https://astro.build/config
export default defineConfig({
  integrations: [svelte()],

  vite: {
    plugins: [tailwindcss()],
  },

  fonts: [
    {
      provider: fontProviders.local(),
      name: "Iosevka Charon",
      cssVariable: "--font-iosevka",
      options: {
        //@ts-ignore
        variants: generateVariants("iosevka-charon"),
      },
    },
    {
      provider: fontProviders.local(),
      name: "Iosevka Charon Mono",
      cssVariable: "--font-iosevka-mono",
      options: {
        //@ts-ignore
        variants: generateVariants("iosevka-charon-mono"),
      },
    },
  ],
});
