{
  coreutils,
  fetchurl,
  gnutar,
  gawk,
  lib,
  stdenv,
}:
let
  version = "0.6.6-rc.2";
  srcs = [
    (fetchurl {
      url = "https://github.com/Jake-Shadle/xwin/releases/download/${version}/xwin-${version}-x86_64-unknown-linux-musl.tar.gz";
      sha256 = "sha256-V3Ul0v9qE11K6ILIyfbzjGex09n62Mi0HX5VGZdBMmo=";
    })
    (fetchurl {
      url = "https://github.com/Jake-Shadle/xwin/releases/download/${version}/xwin-${version}-x86_64-unknown-linux-musl.tar.gz.sha256";
      sha256 = "sha256-3EKVO6KA//eDdI0dtxUhp7bXCzZUikHltifq9tMCw2g=";
    })
  ];
in
stdenv.mkDerivation {
  pname = "xwin-downloader";
  inherit srcs version;

  buildInputs = [
    gawk
    coreutils
    gnutar
  ];

  unpackPhase = "true"; # don't unpack the tarballs automatically
  buildPhase = ''
    echo "Verifying sha256 checksum..."

    tarball=$(basename ${builtins.elemAt srcs 0})
    checksum_file=$(basename ${builtins.elemAt srcs 1})

    cp ${builtins.elemAt srcs 0} ./$tarball
    cp ${builtins.elemAt srcs 1} ./$checksum_file

    expected_hash=$(cat $checksum_file | awk '{print $1}')
    actual_hash=$(sha256sum $tarball | awk '{print $1}')

    echo "Expected: $expected_hash"
    echo "Actual:   $actual_hash"

    if [ "$expected_hash" != "$actual_hash" ]; then
      echo "Checksum mismatch!"
      exit 1
    fi
    echo "Checksum OK!"
  '';

  installPhase = ''
    mkdir -p $out/bin
    tar xzf $tarball
    cp xwin-${version}-x86_64-unknown-linux-musl/* $out/bin
  '';

  meta = {
    description = "Downloader for xwin tarball with sha256 verification";
    license = lib.licenses.mit;
  };
}
