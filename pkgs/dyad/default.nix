# pkgs/dyad/default.nix
# Обёртка над официальным .deb релиза dyad-sh/dyad (Electron-приложение,
# в npm отсутствует — имя `dyad` занято чужим пакетом).
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  git,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libgbm,
  libsecret,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
}:

stdenv.mkDerivation rec {
  pname = "dyad";
  version = "1.15.0";

  src = fetchurl {
    url = "https://github.com/dyad-sh/dyad/releases/download/v${version}/dyad_${version}_amd64.deb";
    sha256 = "sha256-+eXXRifRipDWjO2MLITaFD8tEZAo4mMUP1OpZzL1n2I=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libsecret
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    mesa
    nspr
    nss
    pango
    systemd
  ];

  # В архиве нет configure/Makefile — только распаковка и раскладка файлов.
  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    # --no-same-permissions: в песочнице нельзя выставить setuid-бит
    # chrome-sandbox (из /nix/store setuid всё равно не работает —
    # Electron использует userns-песочницу).
    dpkg-deb --fsys-tarfile $src | tar -x --no-same-permissions --no-same-owner
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r usr/* $out/
    rm -rf $out/share/doc $out/share/lintian

    # .desktop из пакета ссылается на `dyad` из PATH — прописываем абсолютный путь.
    substituteInPlace $out/share/applications/dyad.desktop \
      --replace-fail 'Exec=dyad %U' "Exec=$out/bin/dyad %U"

    # Встроенный dugite-git не запустить: его git-remote-http требует
    # Debian-версий символов CURL_GNUTLS_3, которых нет в nixpkgs
    # (у nixpkgs curl только CURL_GNUTLS_4). Подменяем встроенный git
    # системным из nixpkgs — dugite вызывает его по пути resources/git.
    rm -rf $out/lib/dyad/resources/git
    mkdir -p $out/lib/dyad/resources/git
    ln -s ${lib.getBin git}/bin $out/lib/dyad/resources/git/bin
    ln -s ${git}/libexec $out/lib/dyad/resources/git/libexec
    ln -s ${git}/share $out/lib/dyad/resources/git/share

    runHook postInstall
  '';

  meta = with lib; {
    description = "Local, open-source AI app builder";
    homepage = "https://dyad.sh";
    # Код вне src/pro — Apache-2.0, внутри src/pro — Fair Source (FSL-1.1).
    license = licenses.fsl11Asl20;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "dyad";
  };
}
