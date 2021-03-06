pkg_name=shield-agent
pkg_origin=starkandwayne
pkg_version="0.10.8"
pkg_maintainer="Justin Carter <justin@starkandwayne.com>"
pkg_license=('MIT')
pkg_description="A standalone system that can perform backup and restore functions for a wide variety of pluggable data systems."
pkg_upstream_url="https://github.com/starkandwayne/shield"
pkg_source="https://github.com/starkandwayne/shield/archive/v${pkg_version}.tar.gz"
pkg_shasum="919324a9fbf307d99c205bf252cf6df72fe6ad43db7cef96c78c299e1b62b36a"
pkg_dirname="shield-${pkg_version}"

pkg_deps=(
  core/bash
  core/bzip2
  core/cacerts
  core/coreutils
  core/curl
  core/glibc
  core/jq-static
  core/libarchive
)
pkg_build_deps=(
  core/gcc
  core/git
  core/go
  core/gox
  core/make
)

pkg_bin_dirs=(bin)

pkg_exports=(
  [port]=port
)
pkg_exposes=(port)

pkg_binds_optional=(
  [daemon]="port provisioning_key"
)

pkg_svc_user="root"
pkg_svc_group="$pkg_svc_user"


do_begin() {
  export SHIELD_SRC_PATH=${HAB_CACHE_SRC_PATH}/$pkg_dirname/src/github.com/starkandwayne/shield
  export GOPATH="$HAB_CACHE_SRC_PATH/$pkg_dirname"
}

do_prepare() {
  rm -rf $HAB_CACHE_SRC_PATH/shield
  mkdir -p ${HAB_CACHE_SRC_PATH}/shield
  mv $HAB_CACHE_SRC_PATH/$pkg_dirname/* $HAB_CACHE_SRC_PATH/shield/

  mkdir -p ${SHIELD_SRC_PATH}
  mv $HAB_CACHE_SRC_PATH/shield/* ${SHIELD_SRC_PATH}

  export PATH=$PATH:$GOPATH/bin

  git config --global url."git://github.com/".insteadOf "https://github.com/"
  go get github.com/tools/godep
  cd ${SHIELD_SRC_PATH}
  make restore-deps
}

do_build() {
  export VERSION=${pkg_version}
  cd ${SHIELD_SRC_PATH}
  make release
}

do_install() {
  cd ${SHIELD_SRC_PATH}/artifacts
  tar -xvzf shield-server-linux-amd64.tar.gz
  cd shield-server-linux-amd64

  cp cli/shield           ${pkg_prefix}/bin
  cp agent/shield-agent   ${pkg_prefix}/bin
  cp -R plugins            ${pkg_prefix}/plugins
  cp daemon/shield-pipe   ${pkg_prefix}/bin
  fix_interpreter ${pkg_prefix}/bin/shield-pipe core/bash bin/bash
}
