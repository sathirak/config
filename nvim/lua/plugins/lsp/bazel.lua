-- lsp/bazel: starpls (Starlark/Bazel) + buildifier
-- Aspect's `bzl` CLI fails to download via Mason (get.bzl.io); starpls is the free LSP.
return {
  servers = {
    starpls = {
      root_markers = { 'MODULE.bazel', 'WORKSPACE', 'WORKSPACE.bazel', 'WORKSPACE.bzlmod' },
    },
  },
  tools = { 'buildifier' },
}
