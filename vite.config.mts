import ViteReact from "@vitejs/plugin-react";
import ViteRails from "vite-plugin-rails";
import ViteYaml from "@modyfi/vite-plugin-yaml";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [ViteReact({ jsxImportSource: "@emotion/react" }), ViteRails({}), ViteYaml()],
});
