{
  buildZedExtension,
}:

buildZedExtension {
  name = "postgrestools";
  version = "0.0.1";

  src = ../../.;

  kind = "rust";

  cargoLock = {
    lockFile = ../../Cargo.lock;
  };
}
