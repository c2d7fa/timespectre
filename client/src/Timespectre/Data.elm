module Timespectre.Data exposing
    ( ActiveSession
    , Session
    , addSession
    , endSession
    , idGenerator
    , isActive
    , setNotes
    )

import Random
import Time


type alias ActiveSession =
    Maybe Time.Posix


type alias Session =
    { id : String
    , start : Time.Posix
    , end : Maybe Time.Posix -- An active session has no end time yet
    , notes : String
    }


isActive : Session -> Bool
isActive session =
    case session.end of
        Just _ ->
            False

        Nothing ->
            True


addSession : String -> Time.Posix -> List Session -> List Session
addSession id start sessions =
    { id = id, start = start, end = Nothing, notes = "" } :: sessions


endSession : Session -> Time.Posix -> List Session -> List Session
endSession session end =
    List.map
        (\s ->
            if s.id == session.id then
                { s | end = Just end }

            else
                s
        )


setNotes : Session -> String -> List Session -> List Session
setNotes session notes =
    List.map
        (\s ->
            if s.id == session.id then
                { s | notes = notes }

            else
                s
        )


idGenerator : Random.Generator String
idGenerator =
    Random.list 6 (Random.int (Char.toCode 'a') (Char.toCode 'z'))
        |> Random.map (List.map Char.fromCode)
        |> Random.map String.fromList
