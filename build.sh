#!/bin/sh

mkdir -p dist

# Static
cp static/*.html dist
sass static/style.scss dist/style.css

# Elm
cd client
elm make src/Main.elm --output=../dist/main.js
cd ..
