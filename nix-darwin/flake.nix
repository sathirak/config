{
  description = "Sathira Workstation Config";

  inputs = {
    # Local absolute path while testing the baseplate; swap to
    # git+https://github.com/ren-org/os-kit.git when published.
    os-kit.url = "path:/Users/sathira/Projects/usm/worktrees/nix/nix2/os-kit";
  };

  outputs =
    { self, os-kit }:
    {
      darwinConfigurations."neptune" = os-kit.lib.mkOS {
        system = "aarch64-darwin";
        hostname = "neptune";
        username = "sathira";

        presets = [
          "base"
        ];

        extraModules = [
          {
            programs.fish.enable = true;
            nixpkgs.config.allowUnfree = true;
            system = {
              configurationRevision = self.rev or self.dirtyRev or null;
              stateVersion = 6;
              primaryUser = "sathira";
            };
          }
          ./configuration.nix
          ./prometheus.nix
          {
            home-manager.backupFileExtension = "backup";
            home-manager.users.sathira = import ./home.nix;
          }
        ];
      };
    };
}
