module Timespectre.View exposing (view)

import Html
import Html.Attributes as Attr
import Html.Events as Ev
import Time
import Timespectre.Data exposing (..)
import Timespectre.Model exposing (..)


view : Model -> Html.Html Msg
view model =
    Html.div [] [ viewActive model.active, viewControls model.active, viewSessions model.sessions ]


viewActive : ActiveSession -> Html.Html Msg
viewActive active =
    case active of
        Nothing ->
            Html.text "No active session."

        Just start ->
            Html.text ("Active session since " ++ formatTime start)


viewControls : ActiveSession -> Html.Html Msg
viewControls active =
    case active of
        Nothing ->
            Html.button [] [ Html.text "Start" ]

        Just _ ->
            Html.button [] [ Html.text "End" ]


viewSessions : List Session -> Html.Html Msg
viewSessions sessions =
    Html.div []
        [ Html.h1 [] [ Html.text "Sessions" ]
        , Html.div [] (List.map viewSession sessions)
        ]


viewSession : Session -> Html.Html Msg
viewSession session =
    Html.div [ Attr.class "session" ]
        [ session.start |> formatTime |> Html.text
        , Html.text " to "
        , session.end |> formatTime |> Html.text
        ]


formatTime : Time.Posix -> String
formatTime time =
    (time |> Time.toYear Time.utc |> String.fromInt)
        ++ "-"
        ++ (time |> Time.toMonth Time.utc |> formatMonth)
        ++ "-"
        ++ (time |> Time.toDay Time.utc |> String.fromInt)
        ++ " "
        ++ (time |> Time.toHour Time.utc |> String.fromInt |> String.padLeft 2 '0')
        ++ ":"
        ++ (time |> Time.toMinute Time.utc |> String.fromInt |> String.padLeft 2 '0')
        ++ ":"
        ++ (time |> Time.toSecond Time.utc |> String.fromInt |> String.padLeft 2 '0')


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
