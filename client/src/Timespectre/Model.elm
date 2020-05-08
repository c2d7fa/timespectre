module Timespectre.Model exposing (EditingTag, Mode(..), Model(..), ModelValue, Msg(..))

import Http
import Time
import Timespectre.Data exposing (Session)


type Mode
    = Sessions
    | Tags


type alias ModelValue =
    { sessions : List Session
    , timeZone : Time.Zone
    , currentTime : Time.Posix
    , editingTag : Maybe EditingTag
    , mode : Mode
    }


type Model
    = Model ModelValue
    | FatalError String


type alias EditingTag =
    { session : Session
    , index : Int
    , buffer : String
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
    | EditTag Session Int
    | AddTag Session
    | SetEditingTagBuffer String
    | SubmitTag
    | ViewSessions
    | ViewTags
