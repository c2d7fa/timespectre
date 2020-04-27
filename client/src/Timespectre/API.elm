module Timespectre.API exposing
    ( deleteSession
    , putNotes
    , putSession
    , requestSessions
    )

import Http
import Json.Decode
import Json.Encode
import Time
import Timespectre.Data exposing (Session)
import Timespectre.Model exposing (Msg(..))


sessionsDecoder : Json.Decode.Decoder (List Session)
sessionsDecoder =
    Json.Decode.list
        (Json.Decode.map4
            (\id start end notes -> { id = id, start = start, end = end, notes = notes })
            (Json.Decode.field "id" Json.Decode.string)
            (Json.Decode.field "start" Json.Decode.int |> Json.Decode.map Time.millisToPosix)
            (Json.Decode.field "end" Json.Decode.int |> Json.Decode.map Time.millisToPosix)
            (Json.Decode.field "notes" Json.Decode.string)
        )


requestSessions : Cmd Msg
requestSessions =
    Http.get { url = "/api/sessions", expect = Http.expectJson FetchedSessions sessionsDecoder }


putSession : Session -> Cmd Msg
putSession session =
    Http.request
        { method = "PUT"
        , headers = []
        , url = "/api/sessions/" ++ session.id
        , body =
            Http.jsonBody
                (Json.Encode.object
                    [ ( "start", Json.Encode.int (Time.posixToMillis session.start) )
                    , ( "end", Json.Encode.int (Time.posixToMillis session.end) )
                    ]
                )
        , expect = Http.expectWhatever DiscardResponse
        , timeout = Nothing
        , tracker = Nothing
        }


putNotes : Session -> String -> Cmd Msg
putNotes session notes =
    Http.request
        { method = "PUT"
        , headers = []
        , url = "/api/sessions/" ++ session.id ++ "/notes"
        , body = Http.jsonBody (Json.Encode.string notes)
        , expect = Http.expectWhatever DiscardResponse
        , timeout = Nothing
        , tracker = Nothing
        }


deleteSession : Session -> Cmd Msg
deleteSession session =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = "/api/sessions/" ++ session.id
        , expect = Http.expectWhatever DiscardResponse
        , timeout = Nothing
        , tracker = Nothing
        , body = Http.emptyBody
        }
