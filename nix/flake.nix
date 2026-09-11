{
  description = "Sathira Workstation Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    os-kit = {
      url = "path:/Users/sathira/Projects/usm/worktrees/nix/nix/os-kit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      os-kit,
      ...
    }:
    let
      hostname = "neptune";
      username = "sathira";
    in
    {
      darwinConfigurations.${hostname} = os-kit.lib.mkSystem {
        system = "aarch64-darwin";
        inherit hostname username;

        modules = [
          os-kit.modules.default

          {
            base = {
              enable = true;
              packages = [ ];
            };

            git = {
              enable = true;
              userName = "Sathira Kulathunga";
              userEmail = "sathira@getren.xyz";
              signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPmePaEvB2BNpv85MUkb/XW3l4tTUnprqyzk7If0w5Wv";
            };

            rust = {
              enable = true;
            };

            nixpkgs.config.allowUnfree = true;
            nix.settings.experimental-features = "nix-command flakes";
            programs.fish.enable = true;

            system = {
              configurationRevision = self.rev or self.dirtyRev or null;
              stateVersion = 6;
              primaryUser = username;
            };

            home-manager.backupFileExtension = "backup";
            home-manager.users.${username} = {
              imports = [ ./home.nix ];
            };
          }

          ./configuration.nix
        ];
      };
    };
}
