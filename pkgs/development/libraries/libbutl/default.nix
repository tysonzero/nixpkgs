{ lib, stdenv
, build2
, fetchurl
, libuuid
, enableShared ? !stdenv.hostPlatform.isStatic
, enableStatic ? !enableShared
}:

stdenv.mkDerivation rec {
  pname = "libbutl";
  version = "0.13.0";

  outputs = [ "out" "dev" "doc" ];

  src = fetchurl {
    url = "https://pkg.cppget.org/1/alpha/build2/libbutl-${version}.tar.gz";
    sha256 = "d7944637ab4a17d3a299c04ff6f146e89b2a0f433ddd9d08d8632a25bae9c9cb";
  };

  nativeBuildInputs = [
    build2
  ];

  strictDeps = true;

  # Should be true for anything built with build2,
  # but especially important when bootstrapping
  disallowedReferences = [ build2 ];

  postPatch = lib.optionalString stdenv.isLinux ''
    substituteInPlace libbutl/uuid-linux.cxx \
      --replace '"libuuid.so' '"${lib.getLib libuuid}/lib/libuuid.so'
  '';

  build2ConfigureFlags = [
    "config.bin.lib=${build2.configSharedStatic enableShared enableStatic}"
  ];

  # tests broken with -DNDEBUG
  # https://github.com/build2/libbutl/issues/4
  # doCheck = true;

  meta = with lib; {
    description = "build2 utility library";
    longDescription = ''
      This library is a collection of utilities that are used throughout the
      build2 toolchain.
    '';
    homepage = "https://build2.org/";
    changelog = "https://git.build2.org/cgit/libbutl/log";
    license = licenses.mit;
    maintainers = with maintainers; [ r-burns ];
  };
}
