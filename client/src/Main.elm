module Main exposing (main)

import Browser
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
      , timeZone = Time.utc
      , currentTime = Time.millisToPosix 0
      , active = Nothing
      }
    , Cmd.batch [ Task.perform SetTimeZone Time.here, API.requestSessions ]
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 250 SetTime


update : Msg -> Model -> ( Model, Cmd.Cmd Msg )
update msg model =
    case msg of
        ToggleActiveSession ->
            case model.active of
                Nothing ->
                    ( startSession model, Cmd.none )

                Just start ->
                    ( model, endSession start )

        SetTimeZone timeZone ->
            ( { model | timeZone = timeZone }, Cmd.none )

        SetTime time ->
            ( { model | currentTime = time }, Cmd.none )

        RecordActiveSession start id ->
            ( recordActiveSession start id model, API.putSession { id = id, start = start, end = model.currentTime, notes = "" } )

        DiscardResponse _ ->
            ( model, Cmd.none )

        FetchedSessions (Err _) ->
            Debug.log "Got error while fetching sessions" ( model, Cmd.none )

        FetchedSessions (Ok sessions) ->
            ( { model | sessions = sessions }, Cmd.none )

        DeleteSession session ->
            ( { model | sessions = List.filter (\s -> s.id /= session.id) model.sessions }, API.deleteSession session )

        SetNotes session notes ->
            ( { model | sessions = setNotes session notes model.sessions }, API.putNotes session notes )


startSession : Model -> Model
startSession model =
    { model | active = Just model.currentTime }


endSession : Time.Posix -> Cmd Msg
endSession start =
    Random.generate (RecordActiveSession start) idGenerator


recordActiveSession : Time.Posix -> String -> Model -> Model
recordActiveSession start id model =
    { model | active = Nothing, sessions = { id = id, start = start, end = model.currentTime, notes = "" } :: model.sessions }
