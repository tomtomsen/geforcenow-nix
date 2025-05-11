{ stdenv
, lib
, electron
, makeWrapper
, nodejs
, yarn
, src
, mkYarnPackage
, fetchYarnDeps
}:

let 
  hashesFile = builtins.fromJSON (builtins.readFile ./hashes.json);
in
mkYarnPackage rec {
  pname = "geforcenow";
  version = "0.1.0";

  inherit src;

  packageJSON = "${src}/package.json";
  yarnLock = "${src}/yarn.lock";

  offlineCache = fetchYarnDeps {
    name = "${pname}-yarn-offline-cache";
    yarnLock = src + "/yarn.lock";
    hash = hashesFile.yarn_offline_cache_hash;
  };

  buildPhase = ''
    echo "Skipping build step"
  '';

  dontDist = true;
  distPhase = "true";  # <-- this disables the default distPhase logic

  installPhase = ''
    mkdir -p $out/opt/geforcenow
    cp -r ${src}/* $out/opt/geforcenow

    mkdir -p $out/bin
    makeWrapper ${electron}/bin/electron $out/bin/geforcenow \
      --add-flags "$out/opt/geforcenow"

    # Desktop entry
    mkdir -p $out/share/applications
    cat > $out/share/applications/geforcenow.desktop <<EOF
[Desktop Entry]
Name=GeForce NOW
Comment=Play PC games via the cloud
Exec=$out/bin/geforcenow
Icon=geforcenow
Terminal=false
Type=Application
Categories=Game;
EOF

    if [ -f icon.png ]; then
      mkdir -p $out/share/icons/hicolor/128x128/apps
      cp icon.png $out/share/icons/hicolor/128x128/apps/geforcenow.png
    fi
  '';

  nativeBuildInputs = [ makeWrapper nodejs yarn ];
  buildInputs = [ electron ];

  meta = with lib; {
    description = "Unofficial GeForce NOW Electron client";
    homepage = "https://www.nvidia.com/en-us/geforce-now/";
    license = licenses.unfreeRedistributable;
    platforms = platforms.linux;
  };
}
