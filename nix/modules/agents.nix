{ pkgs, ... }:

{
  home.packages = [
    # nixpkgs OpenCode 1.18.30 is broken when built with Bun 1.4.x code splitting
    # (Unexpected server error / TypeError: a.name). See NixOS/nixpkgs#563241.
    # Workaround: disable splitting at build time (merged upstream as #564101).
    (pkgs.opencode.overrideAttrs (old: {
      postPatch =
        (old.postPatch or "")
        + ''
          substituteInPlace packages/opencode/script/build.ts \
            --replace-fail 'splitting: true,' 'splitting: false,'
        '';
    }))
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
