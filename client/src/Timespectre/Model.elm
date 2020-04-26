module Timespectre.Model exposing (Model, Msg(..))

import Http
import Time
import Timespectre.Data exposing (ActiveSession, Session)


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
    | FetchedSessions (Result Http.Error (List Session))
    | DeleteSession Session
