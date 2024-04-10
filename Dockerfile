FROM gitpod/workspace-base

ARG TEXLIVE_VERSION=latest
ARG LILYPOND_VERSION=2.24.3

COPY /setup.sh /texlive_pgp_keys.asc /texlive.profile /

RUN sudo install-packages ca-certificates curl libfile-homedir-perl libunicode-linebreak-perl libyaml-tiny-perl perl-doc bzip2 ghostscript

RUN sudo /setup.sh ${TEXLIVE_VERSION} ${LILYPOND_VERSION}
