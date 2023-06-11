{ QuickCheck, aeson, async, attoparsec, autodocodec, base, base64-bytestring,
  byteorder, bytestring, case-insensitive, connection, containers, data-default,
  data-default-class, deepseq, exceptions, ghc-heap-view, graphql-parser, hashable,
  hasura-prelude, http-client, http-client-tls, http-conduit, http-types,
  insert-ordered-containers, kriti-lang, lens, mtl, network, network-bsd,
  network-uri, optparse-generic, pg-client, safe-exceptions,
  refined, scientific, servant-client, template-haskell, text, text-builder,
  text-conversions, time, tls, unordered-containers, uri-encode, wai, websockets,
  wide-word, witherable, x509, x509-store, x509-system, x509-validation, mkDerivation
}:
mkDerivation {
  pname = "hasura-extras";
  version = "1.0.0";
  src = ./.;
  libraryHaskellDepends = [
    QuickCheck aeson async attoparsec autodocodec base base64-bytestring
    byteorder bytestring case-insensitive connection containers data-default
    data-default-class deepseq exceptions ghc-heap-view graphql-parser hashable
    hasura-prelude http-client http-client-tls http-conduit http-types
    insert-ordered-containers kriti-lang lens mtl network network-bsd
    network-uri optparse-generic pg-client safe-exceptions
    refined scientific servant-client template-haskell text text-builder
    text-conversions time tls unordered-containers uri-encode wai websockets
    wide-word witherable x509 x509-store x509-system x509-validation
  ];
  license = "unknown";
}
