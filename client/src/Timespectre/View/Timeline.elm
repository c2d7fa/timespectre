module Timespectre.View.Timeline exposing (viewTimeline)

import Html
import Html.Attributes
import Svg
import Svg.Attributes as Attr
import Time
import Timespectre.Data exposing (..)
import Timespectre.Model exposing (Model, Msg(..))


viewTimeline : Model -> Html.Html Msg
viewTimeline model =
    Html.div [ Html.Attributes.class "timeline" ] [ svgTimeline model ]


svgTimeline : Model -> Html.Html Msg
svgTimeline model =
    Svg.svg [ Attr.width "100%", Attr.height "20" ]
        [ svgSegment model.currentTime 0 (List.head model.sessions |> Maybe.withDefault { start = Time.millisToPosix 0, end = Nothing, id = "error", notes = "", tags = [] })
        ]


svgSegment : Time.Posix -> Int -> Session -> Svg.Svg Msg
svgSegment currentTime offset session =
    let
        end =
            Maybe.withDefault currentTime session.end

        sessionSegment =
            segment currentTime { start = session.start, end = end }

        active =
            session.end |> Maybe.map (\x -> True) |> Maybe.withDefault False
    in
    Svg.rect
        [ Attr.height (20 * offset |> String.fromInt |> (\x -> x ++ "%"))
        , Attr.x sessionSegment.x
        , Attr.width sessionSegment.width
        , Attr.height "12"
        , Attr.rx "3"
        , Attr.class
            (if active then
                "active-segment"

             else
                "segment"
            )
        ]
        []


segment : Time.Posix -> { start : Time.Posix, end : Time.Posix } -> { x : String, width : String }
segment currentTime { start, end } =
    { x = until (Time.posixToMillis currentTime - timelineLengthMs |> Time.millisToPosix) start |> durationLength
    , width = until start end |> durationLength
    }


timelineLengthMs : Int
timelineLengthMs =
    1000 * 60 * 60 * 4


durationLengthRatio : Duration -> Float
durationLengthRatio duration =
    toFloat duration.ms / toFloat timelineLengthMs


durationLength : Duration -> String
durationLength duration =
    duration |> durationLengthRatio |> (\x -> 100 * x) |> String.fromFloat |> (\x -> x ++ "%")
