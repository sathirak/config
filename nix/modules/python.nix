{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    pyenv
    # TODO: manage python using nix
  ];
}
