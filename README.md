# Timespectre

Timespectre is a minimalist time tracking application designed for personal use.
It's built with Elixir and Elm.

## Running

Timespectre is configurable through the following environment variables:

- `TIMESPECTRE_PORT` &ndash; The port on which to listen. (Default: `80`)
- `TIMESPECTRE_DATABASE_PATH` &ndash; An _absolute_ path where the SQLite database should be saved. If the path does not exist, it will be created. (Default: `/var/lib/timespectre/data.db`)

You have two options for running Timespectre. You can either use the Docker
image, or run it directly on a Linux machine with Elixir and Elm.

### With Docker

The official Docker image for Timespectre is `c2d7fa/timespectre`. Run it like so:

    # docker run -ti -v $(pwd)/data:/var/lib/timespectre -p 80 c2d7fa/timespectre

You can configure it through environment variables; see the list above.

If you prefer, you can also build the image yourself:

    # docker build .

### Without Docker

Timespectre is designed for self-hosting on a Linux machine. It requires Elixir
and Mix as well as the Elm Platform to be installed. On Arch Linux, the relevant
packages are `elixir` and `aur/elm-platform-bin`.

You first need to build the static resources and client into the `dist` folder:

    $ ./build.sh

Before running Timespectre the first time, you need to install some dependencies:

    $ cd server
    $ mix local.hex
    $ mix deps.get
    $ cd ..

Then start Timespectre itself:

    $ ./run.sh
