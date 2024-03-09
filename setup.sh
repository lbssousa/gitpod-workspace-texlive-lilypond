#!/bin/sh
set -e

TEXLIVE_VERSION="${1}"
LILYPOND_VERSION="${2}"

install_packages() {
    echo ">>> Running apt-get update..."
    apt-get update -y

    echo ">>> Installing packages: ${@}"
    apt-get -y install --no-install-recommends "${@}"
}


if [ "${VERSION}" = "latest" ]
then
    URL="https://mirror.ctan.org/systems/texlive/tlnet"
else
    URL="http://ftp.math.utah.edu/pub/tex/historic/systems/texlive/${TEXLIVE_VERSION}"
fi

install_packages ca-certificates curl libfile-homedir-perl libunicode-linebreak-perl libyaml-tiny-perl perl-doc

mkdir -p /tmp/install-tl/installer
cd /tmp/install-tl

echo ">>> Downloading TeX Live installer (${TEXLIVE_VERSION})..."
curl -OL ${URL}/install-tl-unx.tar.gz
curl -OL ${URL}/install-tl-unx.tar.gz.sha512
curl -OL ${URL}/install-tl-unx.tar.gz.sha512.asc

echo ">>> Validating TeX Live installer integrity..."
gpg --import /texlive_pgp_keys.asc
gpg --verify ./install-tl-unx.tar.gz.sha512.asc ./install-tl-unx.tar.gz.sha512
sha512sum -c ./install-tl-unx.tar.gz.sha512

echo ">>> Extracting TeX Live installer..."
tar --strip-components 1 -zxf /tmp/install-tl/install-tl-unx.tar.gz -C /tmp/install-tl/installer

echo ">>> Installing TeX Live..."
retry 3 /tmp/install-tl/installer/install-tl -profile=/texlive.profile

TLMGR=$(find /usr/local/texlive -name tlmgr)
echo ">>> tlmgr path: ${TLMGR}"

echo ">>> Creating symlinks to TeX Live binaries under system PATH..."
${TLMGR} path add || true

# LilyPond Install

LILYPOND_PACKAGE=lilypond-${LILYPOND_VERSION}-linux-x86_64.tar.gz

install_packages bzip2 ghostscript unzip wget

echo ">>> Downloading EB Garamond font..."
curl -L https://github.com/octaviopardo/EBGaramond12/archive/refs/heads/master.zip -o ebgaramond.zip

echo ">>> Installing EB Garamond font to /usr/local/share/fonts..."
unzip ebgaramond.zip
install -Dm644 EBGaramond12-master/fonts/otf/*.otf -t /usr/local/share/fonts/opentype/EBGaramond12

echo ">>> Downloading LilyPond installer, version ${LILYPOND_VERSION}..."
curl -LO https://gitlab.com/lilypond/lilypond/-/releases/v${LILYPOND_VERSION}/downloads/${LILYPOND_PACKAGE}

echo ">>> Installing ${LILYPOND_PACKAGE}..."
tar xzvf ${LILYPOND_PACKAGE} -C /opt

for bin in /opt/lilypond-${LILYPOND_VERSION}/bin/*
do
    echo ">>> Symlinking ${bin} to /usr/local/bin..."
    ln -s ${bin} /usr/local/bin
done

# Clean up
rm -rf ./${LILYPOND_PACKAGE} ./EBGaramond12-master ./ebgaramond.zip
apt-get clean

echo ">>> Done!"