module Timespectre.View.Timeline exposing (viewTimeline)

import Html
import Html.Attributes
import Svg
import Svg.Attributes as Attr
import Time
import Timespectre.Data exposing (..)
import Timespectre.Model exposing (Model, Msg(..))
import Timespectre.Util exposing (divisibleBy, isAfter, rangeBy)


viewTimeline : Model -> Html.Html Msg
viewTimeline model =
    Html.div [ Html.Attributes.class "timeline" ] [ svgTimeline model ]


svgTimeline : Model -> Html.Html Msg
svgTimeline model =
    Svg.svg [ Attr.width "100%", Attr.height "100%" ]
        ([ svgLine, svgTicks ]
            ++ (model.sessions
                    |> List.filter
                        (\session -> session.end |> Maybe.map (isAfter (originTime model.currentTime)) |> Maybe.withDefault True)
                    |> List.map (svgSegment model.currentTime)
               )
        )


svgTicks : Svg.Svg Msg
svgTicks =
    Svg.g []
        (rangeBy 0 timelineLengthMs (1000 * 60 * 15)
            |> List.map (\x -> svgTick (durationLength { ms = x }) (divisibleBy (1000 * 60 * 60) x))
        )


svgTick : String -> Bool -> Svg.Svg Msg
svgTick x large =
    let
        props =
            if large then
                [ Attr.y "25%", Attr.height "50%" ]

            else
                [ Attr.y "35%", Attr.height "30%" ]
    in
    Svg.rect ([ Attr.x x, Attr.width "1px", Attr.fill "#e0e0e0" ] ++ props) []


svgLine : Svg.Svg Msg
svgLine =
    Svg.rect [ Attr.x "0%", Attr.width "100%", Attr.y "50%", Attr.height "1px", Attr.fill "#f0f0f0" ] []


svgSegment : Time.Posix -> Session -> Svg.Svg Msg
svgSegment currentTime session =
    let
        end =
            Maybe.withDefault currentTime session.end

        sessionSegment =
            segment currentTime { start = session.start, end = end }

        active =
            session.end |> Maybe.map (\x -> False) |> Maybe.withDefault True
    in
    Svg.rect
        [ Attr.y "40%"
        , Attr.x sessionSegment.x
        , Attr.width sessionSegment.width
        , Attr.height "20%"
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
    1000 * 60 * 60 * 6


originTime : Time.Posix -> Time.Posix
originTime currentTime =
    Time.millisToPosix (Time.posixToMillis currentTime - timelineLengthMs)


durationLengthRatio : Duration -> Float
durationLengthRatio duration =
    toFloat duration.ms / toFloat timelineLengthMs


durationLength : Duration -> String
durationLength duration =
    duration |> durationLengthRatio |> (\x -> 100 * x) |> String.fromFloat |> (\x -> x ++ "%")
