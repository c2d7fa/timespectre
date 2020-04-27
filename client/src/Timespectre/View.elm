module Timespectre.View exposing (view)

import Html
import Html.Attributes as Attr
import Html.Events as Ev
import Time
import Timespectre.Data exposing (..)
import Timespectre.Model exposing (..)


view : Model -> Html.Html Msg
view model =
    Html.div [] [ viewActive model, viewControls model, viewSessions model ]


viewActive : Model -> Html.Html Msg
viewActive model =
    case model.active of
        Nothing ->
            Html.text "No active session."

        Just start ->
            Html.text ("Active session since " ++ formatTime model.timeZone start)


viewControls : Model -> Html.Html Msg
viewControls model =
    let
        label =
            case model.active of
                Nothing ->
                    "Start"

                Just _ ->
                    "End"
    in
    Html.button [ Ev.onClick ToggleActiveSession ] [ Html.text label ]


viewSessions : Model -> Html.Html Msg
viewSessions model =
    Html.div []
        [ Html.h1 [] [ Html.text "Sessions" ]
        , Html.div [] (List.map (viewSession model.timeZone) model.sessions)
        ]


viewSession : Time.Zone -> Session -> Html.Html Msg
viewSession zone session =
    Html.div [ Attr.class "session" ]
        [ session.start |> formatTime zone |> Html.text
        , Html.text " to "
        , session.end |> formatTime zone |> Html.text
        , Html.code []
            [ Html.text " (ID="
            , Html.text session.id
            , Html.text ")"
            ]
        , Html.textarea
            [ Attr.value session.notes
            , Attr.placeholder "Enter notes here..."
            , Ev.onInput (SetNotes session)
            ]
            []
        , Html.button [ Ev.onClick (DeleteSession session) ] [ Html.text "Delete" ]
        ]


formatTime : Time.Zone -> Time.Posix -> String
formatTime zone time =
    (time |> Time.toYear zone |> String.fromInt)
        ++ "-"
        ++ (time |> Time.toMonth zone |> formatMonth)
        ++ "-"
        ++ (time |> Time.toDay zone |> String.fromInt)
        ++ " "
        ++ (time |> Time.toHour zone |> String.fromInt |> String.padLeft 2 '0')
        ++ ":"
        ++ (time |> Time.toMinute zone |> String.fromInt |> String.padLeft 2 '0')
        ++ ":"
        ++ (time |> Time.toSecond zone |> String.fromInt |> String.padLeft 2 '0')


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
