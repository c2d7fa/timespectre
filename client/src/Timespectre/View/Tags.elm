module Timespectre.View.Tags exposing (viewTags)

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Ev
import Timespectre.Data exposing (Duration)
import Timespectre.Model exposing (ModelValue, Msg(..))
import Timespectre.View.General exposing (viewDuration)


viewTags : ModelValue -> Html Msg
viewTags model =
    case model.tagStats of
        Nothing ->
            Html.text "Loading..."

        Just tagStats ->
            Html.div [ Attr.class "tag-stats-container" ]
                [ viewSinceControl
                , viewTagStats tagStats
                ]


viewSinceControl : Html Msg
viewSinceControl =
    Html.select
        [ Ev.onInput
            (\option ->
                case option of
                    "today" ->
                        ViewTagsToday

                    _ ->
                        ViewTags
            )
        ]
        [ Html.option [ Attr.value "" ] [ Html.text "All Time" ]
        , Html.option [ Attr.value "today" ] [ Html.text "Today" ]
        ]


viewTagStats : Dict String Duration -> Html Msg
viewTagStats tagStats =
    Html.table [ Attr.class "tag-stats" ] (List.map viewRow (sorted tagStats))


viewRow : ( String, Duration ) -> Html Msg
viewRow ( tag, duration ) =
    Html.tr []
        [ Html.td [] [ Html.span [ Attr.class "tag" ] [ Html.text tag ] ]
        , Html.td [] [ viewDuration duration ]
        ]


sorted : Dict String Duration -> List ( String, Duration )
sorted tagStats =
    tagStats |> Dict.toList |> List.sortBy (\( _, duration ) -> -duration.ms)
