module Timespectre.Model exposing (Model, Msg(..))

import Dict exposing (Dict)
import Http
import Time
import Timespectre.Data exposing (Session, State)


type alias Model =
    { sessions : List Session
    , tags : Dict String String
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
