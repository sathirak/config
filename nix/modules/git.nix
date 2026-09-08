{ config, pkgs, ... }:

{
  # Setting up git
  programs.git = {
    enable = true;
    extraConfig = {
      url = {
        "git@github.com:".insteadOf = "https://github.com/";
        "git@github.com:".pushInsteadOf = "https://github.com/";
      };

      user = {
        name = "Sathira Kulathunga";
        email = "sathira@getren.xyz";
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPmePaEvB2BNpv85MUkb/XW3l4tTUnprqyzk7If0w5Wv";
      };

      gpg = {
        format = "ssh";
      };

      commit = {
        gpgsign = true;
      };
      tag = {
        gpgsign = true;
      };
    };
  };
}
