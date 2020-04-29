module Timespectre.Model exposing (Model, Msg(..), State)

import Http
import Time
import Timespectre.Data exposing (Session)


type alias State =
    { sessions : List Session }


type alias Model =
    { sessions : List Session
    , timeZone : Time.Zone
    , currentTime : Time.Posix
    }


type Msg
    = StartSession
    | SessionStarted String
    | EndSession Session
    | SetTimeZone Time.Zone
    | SetTime Time.Posix
    | DiscardResponse (Result Http.Error ())
    | FetchedState (Result Http.Error State)
    | DeleteSession Session
    | SetNotes Session String
