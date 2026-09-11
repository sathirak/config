{ ... }:

{
  imports = [
    ./modules/java.nix
    #./modules/rust.nix
    ./modules/neovim.nix
    ./modules/ssh.nix
    ./modules/fish.nix
    ./modules/jupiter.nix
    ./modules/agents.nix
  ];

  programs.yazi = {
    enable = true;
    shellWrapperName = "yy";
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  home.stateVersion = "25.05";
}
