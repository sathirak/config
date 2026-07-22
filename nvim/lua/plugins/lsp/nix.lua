-- lsp/nix: nixd (flake-aware) + nixfmt
local flake = '(builtins.getFlake "' .. vim.fn.expand '~/.config/nix-darwin' .. '")'

return {
  servers = {
    nixd = {
      settings = {
        nixd = {
          nixpkgs = {
            expr = 'import ' .. flake .. '.inputs.nixpkgs { }',
          },
          formatting = {
            command = { 'nixfmt' },
          },
          options = {
            ['nix-darwin'] = {
              expr = flake .. '.darwinConfigurations.neptune.options',
            },
            home_manager = {
              expr = flake
                .. '.darwinConfigurations.neptune.options.home-manager.users.type.getSubOptions []',
            },
          },
        },
      },
    },
  },
}
