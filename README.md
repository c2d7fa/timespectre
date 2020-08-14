# Timespectre

Timespectre is a minimalist time tracking application designed for personal use.
It's built with Elixir and Elm.

<p align="center"><img src="https://raw.githubusercontent.com/c2d7fa/timespectre/master/screenshot.png"/></p>

**Features:**

* Minimalist, responsive design intended for individuals, not teams.
* Open source with easy setup for self-hosting.
* Overlapping "sessions", organized with tags and free-form notes.
* Timeline for visualizing sessions.

**Try it:**

    $ sudo docker pull c2d7fa/timespectre
    $ sudo docker run --rm -ti -p 8080:80 c2d7fa/timespectre
    $ # Then visit http://localhost:8080/ and make an account.

(This doesn't persist data after the Docker container is stopped. See "With Docker" below for more information.)

## Running

Timespectre is configurable through the following environment variables:

- `TIMESPECTRE_PORT` &ndash; The port on which to listen. (Default: `80`)
- `TIMESPECTRE_DATABASE_PATH` &ndash; An _absolute_ path where the SQLite database should be saved. If the path does not exist, it will be created. (Default: `/var/lib/timespectre/data.db`)

You have two options for running Timespectre. You can either use the Docker
image, or run it directly on a Linux machine with Elixir and Elm.

### With Docker (Recommended)

The official Docker image for Timespectre is `c2d7fa/timespectre`. Run it like so:

    # docker run -ti -v $(pwd)/data:/var/lib/timespectre -p 80 c2d7fa/timespectre

You can configure it through environment variables; see the list above.

If you prefer, you can also build the image yourself from this repository:

    # docker build -t timespectre .
    # docker run -ti -v $(pwd)/data:/var/lib/timespectre -p 80 timespectre

### Without Docker

Timespectre is designed for self-hosting on a Linux machine. It requires Elixir
and Mix as well as the Elm Platform to be installed. On Arch Linux, the relevant
packages are `elixir` and `aur/elm-platform-bin`.

You will also need to have Sass installed, and have the `sass` binary available
in your path. You can install this from NPM with `npm install -g sass`.

You first need to build the static resources and client into the `dist` folder:

    $ ./build.sh

Before running Timespectre the first time, you need to install some dependencies:

    $ cd server
    $ mix local.hex
    $ mix deps.get
    $ cd ..

Then start Timespectre itself:

    $ ./run.sh

## Development

While working on Timespectre, it may be useful to have a standardized development environment. The Dockerfile called `dev.Dockerfile` describes a Docker image that has everything you need for development. Build it with:

    # docker build -t timespectre-dev -f dev.Dockerfile .

Then, run it, and make sure the working directory is mounted in `/work`. You'll probably want to expose port 80:

    # docker run -ti -v $(pwd):/work -p 127.0.0.1:8080:80 timespectre-dev

From inside the Docker image, follow the instructions above (see "Without Docker") to build and run Timespectre. You will need to rerun `./build.sh` each time you change static resources, and `./run.sh` each time you cahnge the Elixir code.
