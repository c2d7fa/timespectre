FROM codesimple/elm:0.19 AS client

RUN mkdir -p /work
WORKDIR /work

COPY build.sh build.sh
COPY static static
COPY client client

RUN ./build.sh

FROM elixir:1.10.1

RUN mkdir -p /timespectre
WORKDIR /timespectre

COPY run.sh run.sh

COPY --from=client /work/dist dist

COPY server server
RUN cd server && mix local.hex --force && mix local.rebar --force && mix deps.get && mix compile && cd ..

EXPOSE 80
ENTRYPOINT ./run.sh
