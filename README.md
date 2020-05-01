# Timespectre

Timespectre is a minimalist time tracking application designed for personal use.
It's built with Elixir and Elm.

## Running

Timespectre is designed for self-hosting on a Linux machine. It requires Elixir and Mix as well as the Elm Platform to be installed. On Arch Linux, the relevant packages are `elixir` and `aur/elm-platform-bin`.

Timespectre is configurable through the following environment variables:

- `TIMESPECTRE_PORT` &ndash; The port on which to listen. (Default: `80`)
- `TIMESPECTRE_DATABASE_PATH` &ndash; An _absolute_ path where the SQLite database should be saved. If the path does not exist, it will be created. (Default: `/var/lib/timespectre/data.db`)

To start Timespectre, simply execute the script `run.sh` in the top-level
directory inside the repository:

    $ ./run.sh
