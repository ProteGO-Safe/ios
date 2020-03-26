#!/bin/bash

cd "$(dirname "$0")/.."
carthage update --no-build
carthage build --no-use-binaries --cache-builds --platform iOS