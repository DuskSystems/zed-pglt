{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  postgresql,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "postgrestools";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "supabase-community";
    repo = "postgres_lsp";
    rev = finalAttrs.version;
    hash = "sha256-K1Z3CnNrpFFMLq7kgifGM1Na3ptdU4JOUnYtzC5zVCs=";
    fetchSubmodules = true;
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-jB2IlfbK52rm+7XJl22xXd9QvsR8RsTMttqAQKhbmD0=";

  cargoBuildFlags = [ "--package=pgt_cli" ];
  cargoTestFlags = [ "--package=pgt_cli" ];

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    pkg-config
    cmake
    postgresql
  ];

  buildInputs = [
    openssl
  ];

  preBuild = ''
    mkdir pgdata
    initdb --pgdata=pgdata --encoding=utf8
    pg_ctl start --pgdata=pgdata --options="--unix-socket-directories=$PWD/pgdata"
    export DATABASE_URL="postgresql:///postgres?host=$PWD/pgdata"
  '';

  postBuild = ''
    pg_ctl stop --pgdata=pgdata --mode=immediate
    rm -rf pgdata
  '';

  postInstall = ''
    mkdir -p $out/share/postgrestools
    cp docs/schemas/latest/schema.json $out/share/postgrestools
  '';

  meta = {
    description = "A collection of language tools and a Language Server Protocol (LSP) implementation for PostgreSQL.";
    homepage = "https://github.com/supabase-community/postgres_lsp";
    changelog = "https://github.com/supabase-community/postgres_lsp/releases";
    license = lib.licenses.mit;
    mainProgram = "postgrestools";
  };
})
