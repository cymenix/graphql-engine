self: super: {
  haskell = super.haskell // {
    packages = super.haskell.packages // {
      ${super.ghcName} = super.haskell.packages.${super.ghcName}.override {
        overrides = hself: hsuper: {
          # NOTE: avoiding IFD's/automatically generated derivations in favor of cabal2nix generated default.nix
          aeson-ordered = hsuper.callPackage ../../server/lib/aeson-ordered { };
          api-tests = hsuper.callPackage ../../server/lib/api-tests { };

          # TODO: some typed hole errors ATM + tests don't compile as extra-source-files are missing
          dc-api = super.haskell.lib.dontCheck (hsuper.callPackage ../../server/lib/dc-api { 
            hasura-extras = hself.hasura-extras;
          });
          hasura-error-message =
            hsuper.callPackage ../../server/lib/error-message { };
          graphql-parser =
            hsuper.callPackage ../../server/lib/graphql-parser {
              hedgehog = hself.hedgehog_1_2;
            };
          hasura-prelude =
            hsuper.callPackage ../../server/lib/hasura-prelude { };
          pg-client = super.haskell.lib.dontCheck
            (hsuper.callPackage ../../server/lib/pg-client {
              resource-pool = hself.hasura-resource-pool;
            });

          hasura-schema-parsers =
            hsuper.callPackage ../../server/lib/schema-parsers { };
          test-harness = hsuper.callPackage ../../server/lib/test-harness { };
          hasura-extras = hsuper.callPackage ../../server/lib/hasura-extras { };

          graphql-server = super.haskell.lib.justStaticExecutables
            ((super.haskell.lib.dontCheck (hsuper.callPackage ../../server {
              hedgehog = hself.hedgehog_1_2;
              immortal = hself.immortal_0_2_2_1;
              pg-client = hself.pg-client;
              odbc = hself.hasura-odbc;
              resource-pool = hself.hasura-resource-pool;
            })));

          # FIXME: for remote repos we have to calculate their default.nix until they get upstreamed/maintained
          # ekg-core = hsuper.callCabal2nix "ekg-core" (super.fetchFromGitHub {
          #   owner = "hasura";
          #   repo = "ekg-core";
          #   rev = "b0cdc337ca2a52e392d427916ba3e28246b396c0";
          #   sha256 = "5hdk6OA6fmXFYxt69mwlFDzCd/sxQIm3kc+NreJBy+s=";
          # }) { };

          # https://gutier.io/post/development-fixing-broken-haskell-packages-nixpkgs/
          ekg-prometheus = super.haskell.lib.doJailbreak
            (hsuper.callCabal2nix "ekg-prometheus" (super.fetchFromGitHub {
              owner = "hasura";
              repo = "ekg-prometheus";
              rev = "131bd4fe72764377d2dae098df0c0e35e3b09982";
              sha256 = "15EqVL+5AWz3588Ilb9dAgb+i9LaUhBEXHZ/f8jp8/4=";
            }) { });

          # FIXME: reenable tests that fail upstream
          kriti-lang = super.haskell.lib.dontCheck (hsuper.callCabal2nix "kriti-lang"
            (super.fetchFromGitHub {
              owner = "hasura";
              repo = "kriti-lang";
              rev = "daf56edd514a3c5439b457f9de08eaf43c876251";
              sha256 = "0hxc32x5dh21wqyr808c6xpw01b5qr90cbakgxlzb9azv75r89ag";
            }) { });

          # https://gutier.io/post/development-fixing-broken-haskell-packages-nixpkgs/
          ekg-json = hsuper.callCabal2nix "ekg-json" (super.fetchFromGitHub {
            owner = "tracsis";
            repo = "ekg-json";
            rev = "504a8f57e4dc69408f1687e775e9fc4ae2c1511d";
            sha256 = "1jalpf01yxhfwbv9l9garn1g4x0qfwr3jrr25fd58p3v5vhjhyrp";
          }) { };

          ci-info = hsuper.callCabal2nix "ci-info" (super.fetchFromGitHub {
            owner = "hasura";
            repo = "ci-info-hs";
            rev = "be578a01979fc95137cc2c84827f9fafb99df60f";
            sha256 = "m2mxYqQphXeiu9YyZ3RgyRT9xDEIT52ScI7vSWqvYFc=";
          }) { };

          hasura-resource-pool = hsuper.callCabal2nix "resource-pool"
            (super.fetchFromGitHub {
              owner = "hasura";
              repo = "pool";
              rev = "c5faf9a358e83eaf15fef0c1e890f463d0022565";
              sha256 = "a8dzt1f/TwVG37rOsL/Bh2K90cDnGgj7HVpL0S3r59A=";
            }) { };

          hasura-odbc = super.haskell.lib.dontCheck (hsuper.callCabal2nix "odbc"
            (super.fetchFromGitHub {
              owner = "fpco";
              repo = "odbc";
              rev = "38e04349fe28a91f189e44bd7783220956d18aae";
              sha256 = "V9MMQTJ6j/lHv0HA34J6XM2dsbT/XTVi6MCCaUpomyo=";
            }) { });

          # broken dependency fixe
          # openapi3-3.2.2: lens >=4.16.1 && <5.2
          openapi3 = super.haskell.lib.doJailbreak hsuper.openapi3;
          servant-openapi3 =
            super.haskell.lib.doJailbreak hsuper.servant-openapi3;
          ghc-heap-view =
            super.haskell.lib.disableLibraryProfiling hsuper.ghc-heap-view;

          th-extras = hsuper.callCabal2nix "th-extras" (super.fetchFromGitHub {
            owner = "erikd";
            repo = "th-extras";
            rev = "5d30687fd1da66386fc582fb685e4e95c23f9b24";
            sha256 = "0abpki0y8y4cavv3k1sbqa3jc62rjr8bj7l8j313kjhn6v4hhg1c";
          }) { };
        };
      };
    };
  };
}
