module Main exposing (main)

import Browser
import Dict
import Random
import Task
import Time
import Timespectre.API as API
import Timespectre.Data exposing (..)
import Timespectre.Model exposing (..)
import Timespectre.View exposing (view)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init () =
    ( { sessions = []
      , tags = Dict.empty
      , timeZone = Time.utc
      , currentTime = Time.millisToPosix 0
      }
    , Cmd.batch [ Task.perform SetTimeZone Time.here, API.requestState ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 250 SetTime


update : Msg -> Model -> ( Model, Cmd.Cmd Msg )
update msg model =
    case msg of
        StartSession ->
            ( model, Random.generate SessionStarted idGenerator )

        SessionStarted id ->
            ( { model | sessions = addSession id model.currentTime model.sessions }, API.putSession { id = id, start = model.currentTime, end = Nothing, notes = "", tags = [] } )

        SetTimeZone timeZone ->
            ( { model | timeZone = timeZone }, Cmd.none )

        SetTime time ->
            ( { model | currentTime = time }, Cmd.none )

        DiscardResponse _ ->
            ( model, Cmd.none )

        FetchedState (Err _) ->
            Debug.log "Got error while fetching state" ( model, Cmd.none )

        FetchedState (Ok state) ->
            ( { model | sessions = state.sessions, tags = state.tags }, Cmd.none )

        DeleteSession session ->
            ( { model | sessions = List.filter (\s -> s.id /= session.id) model.sessions }, API.deleteSession session )

        SetNotes session notes ->
            ( { model | sessions = setNotes session notes model.sessions }, API.putNotes session notes )

        EndSession session ->
            ( { model | sessions = endSession session model.currentTime model.sessions }, API.putEnd session model.currentTime )
