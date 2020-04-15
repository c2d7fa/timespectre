module Timespectre.Model exposing (..)

import Debug
import Http
import Json.Encode
import Random
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
    | RecordActiveSession Time.Posix String
    | SetTimeZone Time.Zone
    | SetTime Time.Posix
    | DiscardResponse (Result Http.Error ())


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
                    ( model, endSession start )

        SetTimeZone timeZone ->
            ( { model | timeZone = timeZone }, Cmd.none )

        SetTime time ->
            ( { model | currentTime = time }, Cmd.none )

        RecordActiveSession start id ->
            ( recordActiveSession start id model
            , Http.request
                { method = "PUT"
                , headers = []
                , url = "/api/sessions/" ++ id
                , body =
                    Http.jsonBody
                        (Json.Encode.object
                            [ ( "start", Json.Encode.int (Time.posixToMillis start) )
                            , ( "end", Json.Encode.int (Time.posixToMillis model.currentTime) )
                            ]
                        )
                , expect = Http.expectWhatever DiscardResponse
                , timeout = Nothing
                , tracker = Nothing
                }
            )

        DiscardResponse _ ->
            ( model, Cmd.none )


startSession : Model -> Model
startSession model =
    { model | active = Just model.currentTime }


endSession : Time.Posix -> Cmd Msg
endSession start =
    Random.generate (RecordActiveSession start) idGenerator


recordActiveSession : Time.Posix -> String -> Model -> Model
recordActiveSession start id model =
    { model | active = Nothing, sessions = { id = id, start = start, end = model.currentTime } :: model.sessions }
