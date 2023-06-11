{ mkDerivation , base , mtl , transformers }:
mkDerivation {
  pname = "arrows-extra";
  version = "1.0.0";
  src = ./.;
  libraryHaskellDepends = [
    base mtl transformers 
  ];
  license = "unknown";
}
