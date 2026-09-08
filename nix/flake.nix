{
  description = "Sathira Workstation Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nix-darwin,
      home-manager,
      ...
    }:
    {
      darwinConfigurations."neptune" = nix-darwin.lib.darwinSystem {
        modules = [
          home-manager.darwinModules.home-manager
          {
            networking.hostName = "neptune";
            nixpkgs.hostPlatform = "aarch64-darwin";
            nixpkgs.config.allowUnfree = true;
            nix.settings.experimental-features = "nix-command flakes";
            programs.fish.enable = true;
            system = {
              configurationRevision = self.rev or self.dirtyRev or null;
              stateVersion = 6;
              primaryUser = "sathira";
            };
            home-manager.backupFileExtension = "backup";
            home-manager.users.sathira = import ./home.nix;
          }
          ./configuration.nix
          ./prometheus.nix
        ];
      };
    };
}
