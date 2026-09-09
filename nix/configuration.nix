{ pkgs, ... }:

{
  users.users.sathira = {
    name = "sathira";
    home = "/Users/sathira";
  };

  # System-only / GUI tools. Editor, LSPs, and CLI language tools live in home.
  environment.systemPackages = with pkgs; [
    lazygit
    maccy
    tree
    quarto
    cmake
    tmux
    statix
    blueutil # overnight sleep prep (`batterysleep`)
    # nixpkgs chmods node_modules/@vscode/ripgrep-universal/..., but the darwin
    # zip ships those binaries under node_modules.asar.unpacked/ instead.
    (vscode.overrideAttrs (_: {
      postPatch = ''
        find Contents -type f -name rg -exec chmod +x {} +
      '';
    }))
  ];

  system.defaults.finder.AppleShowAllExtensions = true;
  # Key repeating rather than press-and-hold accents (requires logout).
  system.defaults.NSGlobalDomain.ApplePressAndHoldEnabled = false;

  system.defaults.CustomUserPreferences = {
    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        "27" = {
          enabled = false;
        };
      };
    };
  };
}
