{ mkDerivation , aeson , arrows-extra , autodocodec
, base , bytestring , cron , hasura-prelude
, hasura-extras , http-types , kriti-lang , lens
, odbc , openapi3 , pg-client , regex-tdfa
, dependent-sum , template-haskell , text , th-lift , time
}:
mkDerivation {
  pname = "hasura-base";
  version = "1.0.0";
  src = ./.;
  libraryHaskellDepends = [ 
    aeson arrows-extra autodocodec
    base bytestring cron hasura-prelude
    hasura-extras http-types kriti-lang lens
    odbc openapi3 pg-client regex-tdfa
    dependent-sum template-haskell text th-lift time
  ];
  license = "unknown";
}
