{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./modules/java.nix
    ./modules/rust.nix
    ./modules/git.nix
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

  home.packages = with pkgs; [
    pyenv
  ];

  home.stateVersion = "25.05";
}
