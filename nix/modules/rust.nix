{ pkgs, lib, ... }:

let
  rustVersion = "1.93";
in
{
  home.packages = with pkgs; [
    rustup
    cargo-generate
    pkg-config
    libiconv
    openssl
  ];

  home.sessionVariables = {
    PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
  };

  # Soft activation: never fail the HM switch if rustup/network is unavailable.
  home.activation.rustup-setup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="$PATH:${pkgs.rustup}/bin"
    if command -v rustup >/dev/null 2>&1; then
      echo "Syncing Rust toolchain ${rustVersion} (best-effort)"
      rustup toolchain install ${rustVersion} >/dev/null 2>&1 || true
      rustup default ${rustVersion} >/dev/null 2>&1 || true
      for component in rustfmt clippy rust-analyzer; do
        rustup component add "$component" >/dev/null 2>&1 || true
      done
    fi
  '';
}
