export default [
  {
    extends: [
      "eslint:recommended",
      "prettier",
      "plugin:prettier/recommended",
      "plugin:react/recommended",
      "plugin:@typescript-eslint/eslint-recommended",
      "plugin:@typescript-eslint/recommended",
    ],
    settings: {
      react: {
        version: "detect",
      },
    },
    plugins: ["prettier", "react", "@typescript-eslint"],
    parserOptions: {
      ecmaVersion: 2020,
      sourceType: "module",
      ecmaFeatures: {
        jsx: true,
      },
    },
    rules: {
      "prettier/prettier": "warn",
      "react/jsx-uses-vars": "error",
      "react/prop-types": "off",
      "react/jsx-uses-react": "off",
      "react/react-in-jsx-scope": "off",
      "max-len": [
        "error",
        {
          code: 120,
        },
      ],
      "react/no-unknown-property": [
        "error",
        {
          ignore: ["css"],
        },
      ],
    },
    env: {
      browser: true,
      node: true,
      es6: true,
    },
  },
];
