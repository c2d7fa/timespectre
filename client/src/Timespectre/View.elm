module Timespectre.View exposing (view)

import Dict exposing (..)
import Html
import Html.Attributes as Attr
import Html.Events as Ev
import Timespectre.Data exposing (..)
import Timespectre.Model exposing (..)
import Timespectre.View.General exposing (viewDuration, viewTime)
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
        , viewNavigation model
        , Html.div [ Attr.class "main-view" ]
            [ case model.mode of
                Sessions ->
                    viewSessions model

                Tags ->
                    viewTags model
            ]
        ]


viewNavigation : ModelValue -> Html.Html Msg
viewNavigation model =
    Html.nav []
        [ Html.ul [ Attr.class "sidebar" ]
            [ Html.li [] [ Html.button [ Ev.onClick StartSession, Attr.class "suggested" ] [ Html.text "Start" ] ]
            , Html.li [] [ viewModeButton model Sessions "Sessions" ViewSessions ]
            , Html.li [] [ viewModeButton model Tags "Tags" ViewTags ]
            , Html.li [] [ Html.button [ Ev.onClick LogOut ] [ Html.text "Log out" ] ]
            ]
        ]


viewModeButton : ModelValue -> Mode -> String -> Msg -> Html.Html Msg
viewModeButton model mode label message =
    Html.button
        [ Ev.onClick message
        , Attr.classList [ ( "active", model.mode == mode ) ]
        ]
        [ Html.text label ]


viewSessions : ModelValue -> Html.Html Msg
viewSessions model =
    Html.ul [ Attr.class "sessions" ] (List.map (viewSession model) model.sessions)


viewSession : ModelValue -> Session -> Html.Html Msg
viewSession model session =
    Html.li
        [ Attr.classList [ ( "outer-session", True ), ( "active", isActive session ) ] ]
        [ Html.div [ Attr.classList [ ( "session", True ), ( "active", isActive session ) ] ]
            [ Html.div [ Attr.class "time" ]
                [ case session.end of
                    Nothing ->
                        viewDuration (until session.start model.currentTime)

                    Just end ->
                        viewDuration (until session.start end)
                , viewTime model.timeZone session.start
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
        [ Html.text "Add tag" ]


viewSessionControls : Session -> Html.Html Msg
viewSessionControls session =
    case session.end of
        Nothing ->
            -- Active session
            Html.div [ Attr.class "session-controls" ]
                [ Html.button [ Ev.onClick (EndSession session), Attr.class "end-button" ] [ Html.text "Stop" ]
                , Html.button [ Ev.onClick (DeleteSession session), Attr.class "delete-button" ] [ Html.text "Delete" ]
                ]

        Just _ ->
            -- Completed session
            Html.div [ Attr.class "session-controls" ]
                [ Html.button [ Ev.onClick (DeleteSession session), Attr.class "delete-button" ] [ Html.text "Delete" ]
                ]
