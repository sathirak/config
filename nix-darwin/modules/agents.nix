{ pkgs, ... }:

{
  home.packages = [
    pkgs.gemini-cli
    pkgs.opencode
    # Official Cursor agent CLI (`cursor-agent`). Also expose `agent`, which is
    # the name the upstream installer puts on PATH.
    (pkgs.cursor-cli.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          ln -sf cursor-agent $out/bin/agent
        '';
    }))
  ];
}
