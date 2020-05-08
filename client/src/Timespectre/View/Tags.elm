module Timespectre.View.Tags exposing (viewTags)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Ev
import Timespectre.Model exposing (ModelValue, Msg)


viewTags : ModelValue -> Html Msg
viewTags model =
    case model.tagStats of
        Nothing ->
            Html.text "Loading..."

        Just tagStats ->
            Html.text (Debug.toString tagStats)
