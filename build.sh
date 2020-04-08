#!/usr/bin/bash

mkdir -p dist

# Static
cp -r static/* dist

# Elm
cd client
elm make src/Main.elm --output=../dist/main.js
cd ..
