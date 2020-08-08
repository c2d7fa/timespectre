# Build static resources, such as SCSS.

FROM node:14.7 AS static

RUN mkdir -p /work
WORKDIR /work

COPY static static

RUN npm install -g sass@^1.26.10

RUN mkdir -p dist
RUN cp static/*.html dist/
RUN sass static/style.scss dist/style.css

# Build Elm client.

FROM codesimple/elm:0.19 AS client

RUN mkdir -p /work
WORKDIR /work

COPY client client

RUN \
  mkdir -p dist && \
  cd client && \
  elm make src/Main.elm --output=../dist/main.js && \
  cd ..

# Build and run Elixir server.

FROM elixir:1.10.1

RUN mkdir -p /timespectre
WORKDIR /timespectre

COPY run.sh run.sh

COPY --from=client /work/dist dist
COPY --from=static /work/dist/* dist/

COPY server server
RUN cd server && mix local.hex --force && mix local.rebar --force && mix deps.get && mix compile && cd ..

EXPOSE 80
ENTRYPOINT ./run.sh
