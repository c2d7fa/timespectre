module Timespectre.View.Tags exposing (viewTags)

import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes as Attr
import Timespectre.Data exposing (Duration)
import Timespectre.Model exposing (ModelValue, Msg)
import Timespectre.View.General exposing (viewDuration)


viewTags : ModelValue -> Html Msg
viewTags model =
    case model.tagStats of
        Nothing ->
            Html.text "Loading..."

        Just tagStats ->
            viewTagStats tagStats


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
