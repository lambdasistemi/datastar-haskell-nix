{
  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    datastar-haskell = {
      url = "github:starfederation/datastar-haskell";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      haskellNix,
      datastar-haskell,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          inherit (haskellNix) config;
          overlays = [ haskellNix.overlay ];
        };
        project = pkgs.haskell-nix.cabalProject' {
          src = datastar-haskell;
          compiler-nix-name = "ghc9122";
          shell = {
            tools = {
              cabal = "latest";
              haskell-language-server = "latest";
              fourmolu = "latest";
            };
            buildInputs = with pkgs; [
              just
            ];
          };
        };
        flake = project.flake { };
      in
      flake
      // {
        packages.default = flake.packages."datastar-hs:lib:datastar-hs";
      }
    );

  nixConfig = {
    extra-substituters = [ "https://cache.iog.io" ];
    extra-trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
    ];
  };
}
