{ stdenv
, lib
, electron
, makeWrapper
, nodejs
, yarn
, src
, mkYarnPackage
, fetchYarnDeps
, makeDesktopItem
, copyDesktopItems
}:

mkYarnPackage rec {
  pname = "geforcenow";
  version = "0.1.0";

  inherit src;

  offlineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    hash = "sha256-cI+ktIvfTvqSDt49Ukm8nux96ZKQ5va2nSibeNc+Lmo=";
  };

  nativeBuildInputs = [ 
    copyDesktopItems
    makeWrapper 
    nodejs
    yarn
  ];
  buildInputs = [ 
    electron
  ];

  doDist = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/geforcenow
    cp -r ${src}/* $out/opt/geforcenow

    mkdir -p $out/bin
    makeWrapper ${electron}/bin/electron $out/bin/geforcenow \
      --add-flags "$out/opt/geforcenow"

    runHook installDesktopItems
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "GeForce NOW";
      genericName = "GeForce NOW";
      comment = "Play PC games via the cloud";
      categories = [
        "Game"
      ];
      exec = "geforcenow";
      icon = "geforcenow";
      terminal = false;
    })
  ];

  meta = with lib; {
    description = "Unofficial GeForce NOW Electron client";
    homepage = "https://www.nvidia.com/en-us/geforce-now/";
    license = licenses.unfreeRedistributable;
    platforms = platforms.linux;
  };
}
