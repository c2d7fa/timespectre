module Timespectre.Data exposing
    ( ActiveSession
    , Session
    , idGenerator
    , setNotes
    )

import Random
import Time


type alias ActiveSession =
    Maybe Time.Posix


type alias Session =
    { id : String
    , start : Time.Posix
    , end : Time.Posix
    , notes : String
    }


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
