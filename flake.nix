{
  inputs = {
    crane = { url = "github:ipetkov/crane?ref=master"; inputs.nixpkgs.follows = "nixpkgs"; };
    fenix = { url = "github:nix-community/fenix?ref=main"; inputs.nixpkgs.follows = "nixpkgs"; };
    flake-utils.url = "github:numtide/flake-utils?ref=main";
    nix-filter.url = "github:numtide/nix-filter?ref=main";
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs: inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      stdenv =
        if pkgs.stdenv.isLinux then
          pkgs.stdenvAdapters.useMoldLinker pkgs.stdenv
        else
          pkgs.stdenv;

      mkToolchain = inputs.fenix.packages.${system}.combine;

      toolchain = inputs.fenix.packages.${system}.stable;

      buildToolchain = mkToolchain (with toolchain; [
        cargo
        rustc
      ]);

      devToolchain = mkToolchain (with toolchain; [
        cargo
        clippy
        llvm-tools
        rust-src
        rustc

        # Always use nightly rustfmt because most of its options are unstable
        inputs.fenix.packages.${system}.latest.rustfmt
      ]);

      builder = (
        (inputs.crane.mkLib pkgs).overrideToolchain buildToolchain
      ).buildPackage;
    in
    {
      packages.default = builder {
        src = let filter = inputs.nix-filter.lib; in filter {
          root = ./.;
          include = [
            "Cargo.lock"
            "Cargo.toml"
            "README.md"
            "src"
          ];
        };

        inherit stdenv;
      };

      devShells.default = (pkgs.mkShell.override { inherit stdenv; }) {
        env = {
          # Rust Analyzer needs to be able to find the path to default crate
          # sources, and it can read this environment variable to do so. The
          # `rust-src` component is required in order for this to work.
          RUST_SRC_PATH = "${devToolchain}/lib/rustlib/src/rust/library";
        };

        packages = [
          devToolchain
        ] ++ (with pkgs; [
          cargo-llvm-cov
          engage
          nixpkgs-fmt
        ]) ++ (with pkgs.nodePackages; [
          markdownlint-cli
        ]);
      };
    });
}
