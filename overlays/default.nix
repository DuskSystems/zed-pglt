final: prev: {
  postgrestools = prev.callPackage ../pkgs/postgrestools { };

  zed-extensions = prev.zed-extensions // {
    postgrestools = prev.callPackage ../pkgs/zed-postgrestools { };
  };
}
