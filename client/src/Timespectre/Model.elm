module Timespectre.Model exposing (Model, Msg(..))

import Http
import Time
import Timespectre.Data exposing (Session)


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
    | FetchedSessions (Result Http.Error (List Session))
    | DeleteSession Session
    | SetNotes Session String
