module Timespectre.View exposing (view)

import Dict exposing (..)
import Html
import Html.Attributes as Attr
import Html.Events as Ev
import Time
import Timespectre.Data exposing (..)
import Timespectre.Model exposing (..)
import Timespectre.View.Tags exposing (viewTags)
import Timespectre.View.Timeline exposing (viewTimeline)


view : Model -> Html.Html Msg
view model =
    case model of
        Model value ->
            viewValue value

        FatalError error ->
            viewError error


viewError : String -> Html.Html Msg
viewError error =
    Html.div [ Attr.class "fatal-error" ]
        [ Html.h1 [] [ Html.text "Fatal error" ]
        , Html.p [] [ Html.text error ]
        ]


viewValue : ModelValue -> Html.Html Msg
viewValue model =
    Html.div [ Attr.class "main-container" ]
        [ viewTimeline model
        , viewSidebar model
        , Html.div [ Attr.class "main-view" ]
            [ case model.mode of
                Sessions ->
                    viewSessions model

                Tags ->
                    viewTags model
            ]
        ]


viewSidebar : ModelValue -> Html.Html Msg
viewSidebar model =
    Html.ul [ Attr.class "sidebar" ]
        [ Html.li [] [ Html.button [ Ev.onClick StartSession ] [ Html.text "Start Session" ] ]
        , Html.li [] [ Html.button [ Ev.onClick ViewSessions ] [ Html.text "Sessions >" ] ]
        , Html.li [] [ Html.button [ Ev.onClick ViewTags ] [ Html.text "Tags >" ] ]
        ]


viewSessions : ModelValue -> Html.Html Msg
viewSessions model =
    Html.ul [ Attr.class "sessions" ] (List.map (viewSession model) model.sessions)


viewSession : ModelValue -> Session -> Html.Html Msg
viewSession model session =
    Html.li
        [ Attr.classList [ ( "outer-session", True ), ( "active", isActive session ) ] ]
        [ Html.div [ Attr.classList [ ( "session", True ), ( "active", isActive session ) ] ]
            [ Html.div [ Attr.class "time" ]
                [ viewTime model.timeZone session.start
                , case session.end of
                    Nothing ->
                        Html.span [] []

                    Just end ->
                        Html.span [] [ Html.span [ Attr.class "ui-text" ] [ Html.text " to " ], viewTime model.timeZone end ]
                , case session.end of
                    Nothing ->
                        Html.span [ Attr.class "duration" ] [ Html.text (formatDuration (until session.start model.currentTime)) ]

                    Just end ->
                        Html.span [ Attr.class "duration" ] [ Html.text (formatDuration (until session.start end)) ]
                ]
            , Html.span [ Attr.class "tags" ]
                (List.map (viewTag model.editingTag session) (List.range 0 (List.length session.tags - 1))
                    ++ [ viewAddTagButton session ]
                )
            , Html.textarea
                [ Attr.value session.notes
                , Attr.placeholder "Enter notes here..."
                , Ev.onInput (SetNotes session)
                ]
                []
            , viewSessionControls session
            ]
        ]


viewTag : Maybe EditingTag -> Session -> Int -> Html.Html Msg
viewTag editingTag session index =
    case editingTag of
        Just inner ->
            if ( inner.session, inner.index ) == ( session, index ) then
                Html.input
                    [ Attr.class "editing-tag"
                    , Ev.onInput SetEditingTagBuffer
                    , Attr.value inner.buffer
                    , Ev.onBlur SubmitTag
                    ]
                    []

            else
                viewStaticTag session index

        Nothing ->
            viewStaticTag session index


viewStaticTag : Session -> Int -> Html.Html Msg
viewStaticTag session index =
    Html.button
        [ Attr.class "tag"
        , Ev.onClick (EditTag session index)
        ]
        [ Html.text (nthTag session index) ]


viewAddTagButton : Session -> Html.Html Msg
viewAddTagButton session =
    Html.button
        [ Attr.class "add-tag"
        , Ev.onClick (AddTag session)
        ]
        [ Html.text "+" ]


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
