{
  description = "Application packaged using poetry2nix";

  nixConfig = {
    extra-substituters = [
      "https://ros.cachix.org"
      "https://nix-community.cachix.org"
      "https://genki.cachix.org"
    ];
    extra-trusted-public-keys = [
      "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "genki.cachix.org-1:5l+wAa4rDwhcd5Wm43eK4N73qJ6GIKmJQ87Nw/bRGfE="
    ];
  };

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell.url = "github:numtide/devshell";
  };

  outputs = { self, nixpkgs, flake-parts, poetry2nix, devshell }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ devshell.flakeModule ];

      systems = [ "x86_64-linux" "aarch64-darwin" ];

      perSystem = { pkgs, system, ... }:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ inputs.poetry2nix.overlays.default ];
          };
          overrides = pkgs.poetry2nix.overrides.withDefaults (final: prev: {
            myapp = prev.myapp.overridePythonAttrs (old: {
              nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.pytestCheckHook ];
            });
          });
          app = pkgs.poetry2nix.mkPoetryEnv {
            projectDir = self;
            inherit overrides;
          };
        in
        {
          packages = rec {
            myapp = pkgs.poetry2nix.mkPoetryApplication {
              projectDir = self;
              pythonImportsCheck = [ "app" ];
              inherit overrides;
            };
            default = myapp;
          };
          devshells.default = {
            packages = [
              app
              pkgs.poetry
            ];
            # env = [
            #   {
            #     name = "PYTHONHOME";
            #     value = app;
            #   }
            # ];
          };
        };
    };
}
