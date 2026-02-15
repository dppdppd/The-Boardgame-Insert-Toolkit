import { defineConfig } from "vite";
import { svelte, vitePreprocess } from "@sveltejs/vite-plugin-svelte";

export default defineConfig({
  plugins: [
    svelte({
      preprocess: vitePreprocess(),
    }),
  ],
  base: "./",
  build: {
    outDir: "dist",
    target: "chrome120",
    minify: "esbuild",
  },
});
