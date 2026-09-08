-- lsp/nix: nixd (flake-aware) + nixfmt
local personal = '(builtins.getFlake "/Users/sathira/.config/nix")'

return {
  servers = {
    nixd = {
      settings = {
        nixd = {
          nixpkgs = {
            expr = 'import ' .. personal .. '.inputs.nixpkgs { }',
          },
          formatting = {
            command = { 'nixfmt' },
          },
          options = {
            ['nix-darwin'] = {
              expr = personal .. '.darwinConfigurations.neptune.options',
            },
            home_manager = {
              expr = personal
                .. '.darwinConfigurations.neptune.options.home-manager.users.type.getSubOptions []',
            },
          },
        },
      },
    },
  },
}
