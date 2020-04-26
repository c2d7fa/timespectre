module Timespectre.API exposing (putSession, requestSessions)

import Http
import Json.Decode
import Json.Encode
import Time
import Timespectre.Data exposing (Session)
import Timespectre.Model exposing (Msg(..))


sessionsDecoder : Json.Decode.Decoder (List Session)
sessionsDecoder =
    Json.Decode.list
        (Json.Decode.map3
            (\id start end -> { id = id, start = start, end = end })
            (Json.Decode.field "id" Json.Decode.string)
            (Json.Decode.field "start" Json.Decode.int |> Json.Decode.map Time.millisToPosix)
            (Json.Decode.field "end" Json.Decode.int |> Json.Decode.map Time.millisToPosix)
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
