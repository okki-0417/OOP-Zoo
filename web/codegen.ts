import type { CodegenConfig } from "@graphql-codegen/cli";

const config: CodegenConfig = {
  schema: "../schema.graphql",
  documents: ["src/**/*.{ts,vue}", "!src/api/generated/**"],
  ignoreNoDocuments: true,
  generates: {
    "src/api/generated/": {
      preset: "client",
      presetConfig: { fragmentMasking: false },
      config: { documentMode: "string", enumsAsTypes: true, useTypeImports: true },
    },
  },
};

export default config;
