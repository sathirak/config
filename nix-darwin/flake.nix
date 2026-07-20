{
  description = "Macos nix flake setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
            vim
          ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin
          programs.fish.enable = true;
          system = {

            # Set Git commit hash for darwin-version.
            configurationRevision = self.rev or self.dirtyRev or null;

            # Used for backwards compatibility, please read the changelog before changing.
            # $ darwin-rebuild changelog
            stateVersion = 6;

            primaryUser = "sathira";
          };

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Home Manager (macOS or NixOS): cloudflared + SSH for lab.ren.lk
      homeManagerModules.jupiter-client = import ./modules/jupiter-client.nix;

      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#neptune
      darwinConfigurations."neptune" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          ./configuration.nix
          ./prometheus.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.users.sathira = import "${toString ./.}/home.nix";
            home-manager.backupFileExtension = "backup";
          }
        ];
      };
    };
}
