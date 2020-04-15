module Timespectre.Model exposing (..)

import Debug
import Task
import Time
import Timespectre.Data exposing (..)


type alias Model =
    { sessions : List Session
    , active : ActiveSession
    , timeZone : Time.Zone
    , currentTime : Time.Posix
    }


type Msg
    = ToggleActiveSession
    | SetTimeZone Time.Zone
    | SetTime Time.Posix


init : () -> ( Model, Cmd Msg )
init () =
    ( { sessions = []
      , timeZone = Time.utc
      , currentTime = Time.millisToPosix 0
      , active = Nothing
      }
    , Task.perform SetTimeZone Time.here
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 250 SetTime


update msg model =
    case msg of
        ToggleActiveSession ->
            case model.active of
                Nothing ->
                    ( startSession model, Cmd.none )

                Just start ->
                    ( endSession start model, Cmd.none )

        SetTimeZone timeZone ->
            ( { model | timeZone = timeZone }, Cmd.none )

        SetTime time ->
            ( { model | currentTime = time }, Cmd.none )


startSession : Model -> Model
startSession model =
    { model | active = Just model.currentTime }


endSession : Time.Posix -> Model -> Model
endSession start model =
    { model | active = Nothing, sessions = { start = start, end = model.currentTime } :: model.sessions }
