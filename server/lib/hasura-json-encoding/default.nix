{ 
mkDerivation, aeson , aeson-ordered , base
, bytestring , hasura-extras , hasura-prelude
, insert-ordered-containers
, pg-client , text , vector
}:
mkDerivation {
  pname = "hasura-json-encoding";
  version = "1.0.0";
  src = ./.;
  libraryHaskellDepends = [ 
    aeson aeson-ordered base
    bytestring hasura-extras hasura-prelude
    insert-ordered-containers
    pg-client text vector
  ];
  license = "unknown";
}
