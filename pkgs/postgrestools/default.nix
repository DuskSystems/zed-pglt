{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  postgresql,
  openssl,
}:

rustPlatform.buildRustPackage {
  pname = "postgrestools";
  version = " 0.2.0";

  src = fetchFromGitHub {
    owner = "supabase-community";
    repo = "postgres_lsp";
    tag = "0.2.0";
    hash = "sha256-WUdO95vFsBsaMhEowPruEytUuh8jHqmeJUvkoXqlqYM=";
    fetchSubmodules = true;
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-RK5cyA7XnQcwa6dvJBgIMY64ezIX1boqmS964qavaqA=";

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
}
