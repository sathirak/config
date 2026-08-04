-- lsp/bazel: starpls (Starlark/Bazel)
return {
  servers = {
    starpls = {
      root_markers = { 'MODULE.bazel', 'WORKSPACE', 'WORKSPACE.bazel', 'WORKSPACE.bzlmod' },
    },
  },
}
