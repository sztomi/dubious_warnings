#! /usr/bin/bash
set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

pkgs=(ffmpeg fontconfig harfbuzz zlib)
ns=""
export CONAN_USER_HOME=$DIR/conan_cache

rm -rf $CONAN_USER_HOME

# conan config set general.revisions_enabled=1
# conan config set general.default_package_id_mode=recipe_revision_mode

for pkg in "${pkgs[@]}"; do
  pushd $pkg
  conan export . $ns
  popd
done


pushd variant
conan export . $ns
conan graph lock .
conan graph build-order --build cascade --build outdated conan.lock
popd

exit

for pkg in "${pkgs[@]}"; do
  pushd $pkg
  conan create . $ns --build missing
  popd
done
