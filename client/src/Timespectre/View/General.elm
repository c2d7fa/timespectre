module Timespectre.View.General exposing (viewDuration, viewTime)

import Html exposing (Html)
import Html.Attributes as Attr
import Time
import Timespectre.Data exposing (Duration)
import Timespectre.Model exposing (Msg)


viewDuration : Duration -> Html Msg
viewDuration duration =
    Html.span [ Attr.class "duration" ] [ duration |> formatDuration |> Html.text ]


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


durationMixed : Duration -> { hours : Int, minutes : Int, seconds : Int, ms : Int }
durationMixed { ms } =
    { hours = ms // (1000 * 60 * 60)
    , minutes = modBy 60 (ms // (1000 * 60))
    , seconds = modBy 60 (ms // 1000)
    , ms = modBy 1000 ms
    }


viewTime : Time.Zone -> Time.Posix -> Html Msg
viewTime zone time =
    Html.time [ Attr.datetime (formatTime zone time) ] [ Html.text (formatTime zone time) ]


formatTime : Time.Zone -> Time.Posix -> String
formatTime zone time =
    (time |> Time.toDay zone |> String.fromInt)
        ++ " "
        ++ (time |> Time.toMonth zone |> formatMonth)
        ++ ", "
        ++ (time |> Time.toYear zone |> String.fromInt)
        ++ " "
        ++ (time |> Time.toHour zone |> String.fromInt |> String.padLeft 2 '0')
        ++ ":"
        ++ (time |> Time.toMinute zone |> String.fromInt |> String.padLeft 2 '0')


formatMonth : Time.Month -> String
formatMonth m =
    case m of
        Time.Jan ->
            "Jan"

        Time.Feb ->
            "Feb"

        Time.Mar ->
            "Mar"

        Time.Apr ->
            "Apr"

        Time.May ->
            "May"

        Time.Jun ->
            "Jun"

        Time.Jul ->
            "Jul"

        Time.Aug ->
            "Aug"

        Time.Sep ->
            "Sep"

        Time.Oct ->
            "Oct"

        Time.Nov ->
            "Nov"

        Time.Dec ->
            "Dec"
