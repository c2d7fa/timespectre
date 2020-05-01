# Timespectre

Timespectre is a minimalist time tracking application designed for personal use.
It's built with Elixir and Elm.

## Running

Timespectre is designed for self-hosting on a Linux machine. It requires Elixir and Mix as well as the Elm Platform to be installed. On Arch Linux, the relevant packages are `elixir` and `aur/elm-platform-bin`.

Timespectre is configurable through the following environment variables:

- `TIMESPECTRE_PORT` &ndash; The port on which to listen, e.g. `80`.

To start Timespectre, simply execute the script `run.sh` in the top-level
directory inside the repository:

    $ ./run.sh
