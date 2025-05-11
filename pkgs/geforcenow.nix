{ stdenv
, lib
, electron
, makeWrapper
, nodejs
, yarn
, src
, node-modules
}:

stdenv.mkDerivation rec {
  pname = "geforcenow";
  version = "0.1.0";

  inherit src;

  nativeBuildInputs = [ makeWrapper nodejs yarn ];
  buildInputs = [ electron node-modules ];

  installPhase = ''
    mkdir -p $out/opt/geforcenow
    cp -r * $out/opt/geforcenow

    ls -la $out/opt/geforcenow

    cd $out/opt/geforcenow
    yarn install --production

    mkdir -p $out/bin
    makeWrapper ${electron}/bin/electron $out/bin/geforcenow \
      --add-flags "$out/opt/geforcenow"

    # Desktop entry
    mkdir -p $out/share/applications
    cat > $out/share/applications/geforcenow.desktop <<EOF
[Desktop Entry]
Name=GeForce NOW
Comment=Play PC games via the cloud
Exec=${placeholder "out"}/bin/geforcenow
Icon=geforcenow
Terminal=false
Type=Application
Categories=Game;Utility;
EOF

    # Optional icon install (if you have e.g. icon.png in src)
    if [ -f icon.png ]; then
      mkdir -p $out/share/icons/hicolor/128x128/apps
      cp icon.png $out/share/icons/hicolor/128x128/apps/geforcenow.png
    fi
  '';

  meta = with lib; {
    description = "GeForce NOW Electron client (unofficial)";
    homepage = "https://www.nvidia.com/en-us/geforce-now/";
    license = licenses.unfreeRedistributable;
    platforms = platforms.linux;
  };
}
