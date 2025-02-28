{
  description = "zed-postgrestools";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };

    zed-extensions = {
      url = "github:DuskSystems/nix-zed-extensions";
    };
  };

  # nix flake show
  outputs =
    {
      self,
      nixpkgs,
      zed-extensions,
      ...
    }:

    let
      perSystem = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;

      systemPkgs = perSystem (
        system:

        import nixpkgs {
          inherit system;

          overlays = [
            self.overlays.default
          ];
        }
      );

      perSystemPkgs = f: perSystem (system: f (systemPkgs.${system}));
    in
    {
      overlays = {
        default = nixpkgs.lib.composeManyExtensions [
          zed-extensions.overlays.default
          (import ./overlays)
        ];
      };

      # nix build .#<name>
      packages = perSystemPkgs (pkgs: {
        postgrestools = pkgs.postgrestools;

        zed-extensions = {
          postgrestools = pkgs.zed-extensions.postgrestools;
        };
      });

      devShells = perSystemPkgs (pkgs: {
        # nix develop
        default = pkgs.mkShell {
          name = "zed-postgrestools-shell";

          env = {
            # Nix
            NIX_PATH = "nixpkgs=${nixpkgs.outPath}";

            # Rust
            RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";
          };

          buildInputs = with pkgs; [
            # Rust
            rustc
            cargo
            clippy
            rustfmt
            rust-analyzer

            # PostgreSQL
            postgrestools

            # TOML
            taplo

            # Nix
            nixfmt-rfc-style
            nixd
            nil
          ];
        };
      });
    };
}
