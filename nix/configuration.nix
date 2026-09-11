{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    lazygit
    tig
    maccy
    tree
    quarto
    cmake
    tmux
    statix
    blueutil
    (vscode.overrideAttrs (_: {
      postPatch = ''
        find Contents -type f -name rg -exec chmod +x {} +
      '';
    }))
  ];

  system.defaults.finder.AppleShowAllExtensions = true;
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
