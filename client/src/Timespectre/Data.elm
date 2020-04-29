module Timespectre.Data exposing
    ( Duration
    , Session
    , addSession
    , addTag
    , endSession
    , formatDuration
    , idGenerator
    , isActive
    , nthTag
    , setNotes
    , setNthTagOfSession
    , until
    )

import Random
import Time


type alias Duration =
    { ms : Int }


type alias Session =
    { id : String
    , start : Time.Posix
    , end : Maybe Time.Posix -- An active session has no end time yet
    , notes : String
    , tags : List String
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
    { id = id, start = start, end = Nothing, notes = "", tags = [] } :: sessions


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


until : Time.Posix -> Time.Posix -> Duration
until t1 t2 =
    { ms = Time.posixToMillis t2 - Time.posixToMillis t1 }


durationMixed : Duration -> { hours : Int, minutes : Int, seconds : Int, ms : Int }
durationMixed { ms } =
    { hours = ms // (1000 * 60 * 60)
    , minutes = modBy 60 (ms // (1000 * 60))
    , seconds = modBy 60 (ms // 1000)
    , ms = modBy 1000 ms
    }


formatDuration : Duration -> String
formatDuration duration =
    let
        { hours, minutes, seconds, ms } =
            durationMixed duration
    in
    case ( hours, minutes, seconds ) of
        ( 0, 0, 0 ) ->
            String.fromInt ms ++ "ms"

        ( 0, 0, _ ) ->
            String.fromInt seconds ++ "s"

        ( 0, _, _ ) ->
            String.fromInt minutes ++ "m" ++ String.fromInt seconds ++ "s"

        ( _, _, _ ) ->
            String.fromInt hours ++ "h" ++ String.fromInt minutes ++ "m"


nthTag : Session -> Int -> String
nthTag session index =
    List.drop index session.tags |> List.head |> Maybe.withDefault "<invalid index>"


setNthTagOfSession : List Session -> Session -> Int -> String -> List Session
setNthTagOfSession sessions session index newTag =
    List.map
        (\s ->
            if s.id == session.id then
                { s
                    | tags =
                        List.take index s.tags
                            ++ (if newTag == "" then
                                    []

                                else
                                    [ newTag ]
                               )
                            ++ List.drop (index + 1) s.tags
                }

            else
                s
        )
        sessions


addTag : List Session -> Session -> String -> ( List Session, Session, Int )
addTag sessions session newTag =
    let
        newSession =
            { session | tags = session.tags ++ [ newTag ] }
    in
    ( List.map
        (\s ->
            if s.id == session.id then
                newSession

            else
                s
        )
        sessions
    , newSession
    , List.length newSession.tags - 1
    )
