#!/bin/sh
set -ex

# delete all (as known in this script), turn off lights
pushd ../lolo-cli/
./lolo.rb light L1 off
./lolo.rb light L2 off
./lolo.rb light L3 off
./lolo.rb delete group All
./lolo.rb delete group G1
./lolo.rb delete group G2
rm -f *_cache.yml
popd
