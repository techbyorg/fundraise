// const presets = ["@babel/env"];
const presets = [
  ["@babel/preset-env", {
    "useBuiltIns": false,
  }],
];
const plugins = [
  "@babel/plugin-transform-runtime"
]

module.exports = { presets, plugins };
