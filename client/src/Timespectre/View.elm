module Timespectre.View exposing (view)

import Dict exposing (..)
import Html
import Html.Attributes as Attr
import Html.Events as Ev
import Time
import Timespectre.Data exposing (..)
import Timespectre.Model exposing (..)


view : Model -> Html.Html Msg
view model =
    Html.div [] [ viewControls model, viewSessions model ]


viewControls : Model -> Html.Html Msg
viewControls model =
    Html.button [ Ev.onClick StartSession ] [ Html.text "Start" ]


viewSessions : Model -> Html.Html Msg
viewSessions model =
    Html.div []
        [ Html.h1 [] [ Html.text "Sessions" ]
        , Html.ul [ Attr.class "sessions" ] (List.map (viewSession model.currentTime model.timeZone) model.sessions)
        ]


viewSession : Time.Posix -> Time.Zone -> Session -> Html.Html Msg
viewSession currentTime zone session =
    Html.li
        [ Attr.classList [ ( "outer-session", True ), ( "active", isActive session ) ] ]
        [ Html.div [ Attr.classList [ ( "session", True ), ( "active", isActive session ) ] ]
            [ Html.div [ Attr.class "time" ]
                [ viewTime zone session.start
                , case session.end of
                    Nothing ->
                        Html.span [] []

                    Just end ->
                        Html.span [] [ Html.span [ Attr.class "ui-text" ] [ Html.text " to " ], viewTime zone end ]
                , case session.end of
                    Nothing ->
                        Html.span [ Attr.class "duration" ] [ Html.text (formatDuration (until session.start currentTime)) ]

                    Just end ->
                        Html.span [ Attr.class "duration" ] [ Html.text (formatDuration (until session.start end)) ]
                ]
            , Html.span [ Attr.class "tags" ]
                (List.map viewTag session.tags
                    ++ [ viewAddTagButton session ]
                )
            , Html.textarea
                [ Attr.value session.notes
                , Attr.placeholder "Enter notes here..."
                , Ev.onInput (SetNotes session)
                ]
                []
            , viewId session
            , viewSessionControls session
            ]
        ]


viewTag : String -> Html.Html Msg
viewTag tag =
    Html.span [ Attr.class "tag" ] [ Html.text tag ]


viewAddTagButton : Session -> Html.Html Msg
viewAddTagButton session =
    Html.button [ Attr.class "add-tag" ]
        [ if List.isEmpty session.tags then
            Html.text "Add Tag"

          else
            Html.text "+"
        ]


viewSessionControls : Session -> Html.Html Msg
viewSessionControls session =
    case session.end of
        Nothing ->
            -- Active session
            Html.div [ Attr.class "session-controls" ]
                [ Html.button [ Ev.onClick (EndSession session), Attr.class "end-button" ] [ Html.text "End" ]
                , Html.button [ Ev.onClick (DeleteSession session), Attr.class "delete-button" ] [ Html.text "Delete" ]
                ]

        Just _ ->
            -- Completed session
            Html.div [ Attr.class "session-controls" ]
                [ Html.button [ Ev.onClick (DeleteSession session), Attr.class "delete-button" ] [ Html.text "Delete" ]
                ]


viewId : Session -> Html.Html Msg
viewId session =
    Html.span [ Attr.class "ui-text id" ] [ Html.text session.id ]


viewTime : Time.Zone -> Time.Posix -> Html.Html Msg
viewTime zone time =
    Html.time [ Attr.datetime (formatTime zone time) ] [ Html.text (formatTime zone time) ]


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
