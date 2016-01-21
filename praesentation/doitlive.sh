#!/bin/sh
set -ex

pushd ../lolo-cli/
rm -f config.yml
rm -f *_cache.yml
popd

doitlive play session.sh
