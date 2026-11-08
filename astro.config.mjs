// @ts-check
import { defineConfig, fontProviders } from "astro/config";

import svelte from "@astrojs/svelte";
import tailwindcss from "@tailwindcss/vite";

// https://astro.build/config
export default defineConfig({
  integrations: [svelte()],

  vite: {
    plugins: [tailwindcss()],
  },

  fonts: [
    {
      provider: fontProviders.google(),
      name: "Iosevka Charon",
      cssVariable: "--font-iosevka",
    },
    {
      provider: fontProviders.google(),
      name: "Iosevka Charon Mono",
      cssVariable: "--font-iosevka-mono",
      fallbacks: ["monospace"],
    },
  ],
});
