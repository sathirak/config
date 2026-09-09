{ pkgs, ... }:

let
  # nvim-treesitter wants tree-sitter CLI >= 0.26.1; nixpkgs is often older.
  tree-sitter-release =
    {
      "aarch64-darwin" = {
        asset = "tree-sitter-macos-arm64.gz";
        hash = "sha256-gjJU6sKp0AbtA6dBgSZSSc2vWXsXvYCK3GNhDER7sL8=";
      };
      "x86_64-darwin" = {
        asset = "tree-sitter-macos-x64.gz";
        hash = "sha256-IWJ2C9NxtBV7JrNjVQ1drL/vw1n6hebprEsx6ecXrdg=";
      };
    }
    .${pkgs.stdenv.hostPlatform.system} or null;

  tree-sitter-cli =
    if tree-sitter-release == null then
      pkgs.tree-sitter
    else
      pkgs.stdenvNoCC.mkDerivation rec {
        pname = "tree-sitter";
        version = "0.26.1";
        src = pkgs.fetchurl {
          url = "https://github.com/tree-sitter/tree-sitter/releases/download/v${version}/${tree-sitter-release.asset}";
          hash = tree-sitter-release.hash;
        };
        dontUnpack = true;
        installPhase = ''
          mkdir -p $out/bin
          gunzip -c $src > $out/bin/tree-sitter
          chmod +x $out/bin/tree-sitter
        '';
        meta = {
          mainProgram = "tree-sitter";
          description = "tree-sitter CLI ${version} (upstream release binary)";
        };
      };
in
{
  # Do not use programs.neovim — it fights the git-managed ~/.config/nvim.
  home.packages = with pkgs; [
    neovim
    tree-sitter-cli

    # Finder backends (Telescope)
    fzf
    ripgrep
    fd

    # Bazel / Starlark (nvim lsp/bazel.lua)
    buildifier
    starpls

    # Language servers / formatters (Nix owns binaries; nvim only configures)
    nodejs
    nixd
    nixfmt
    lua-language-server
    basedpyright
    ruff
    typescript-language-server
    bash-language-server
    fish-lsp
    shellcheck
    shfmt
    stylua
    prettierd
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
