{ mkDerivation , base , arrows-extra , dependent-map
, dependent-sum , hasura-prelude , profunctors , reflection
, some , unordered-containers, hspec }:
mkDerivation {
  pname = "incremental";
  version = "0.1.0.0";
  src = ./.;
  libraryHaskellDepends = [
    base arrows-extra dependent-map
    dependent-sum hasura-prelude profunctors reflection
    some unordered-containers hspec
  ];
  license = "unknown";
}
