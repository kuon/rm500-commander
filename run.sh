#!/bin/bash



pkill rm500

set -e

echo "Building"
make build

echo "Starting server"

./zig-out/bin/rm500 &

