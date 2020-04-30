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
        ([ svgLine, svgTicks ] ++ List.map (svgSession model) (visibleSessions model))


countOverlaps : Model -> Session -> Int
countOverlaps model session =
    visibleSessions model
        |> List.filter
            (\s ->
                s.end
                    |> Maybe.withDefault model.currentTime
                    |> isAfter (session.end |> Maybe.withDefault model.currentTime)
            )
        |> List.filter (\s -> session.start |> isAfter s.start)
        |> List.length
        |> (\n -> n - 1)


visibleSessions : Model -> List Session
visibleSessions model =
    List.filter
        (\session ->
            session.end
                |> Maybe.map (isAfter (originTime model.currentTime))
                |> Maybe.withDefault True
        )
        model.sessions


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


svgSession : Model -> Session -> Svg.Svg Msg
svgSession model session =
    let
        end =
            Maybe.withDefault model.currentTime session.end

        sessionSegment =
            segment model.currentTime { start = session.start, end = end }

        active =
            session.end |> Maybe.map (\x -> False) |> Maybe.withDefault True
    in
    Svg.rect
        [ Attr.y (yFromOverlaps (countOverlaps model session))
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


yFromOverlaps : Int -> String
yFromOverlaps n =
    case n of
        0 ->
            "40%"

        1 ->
            "62%"

        2 ->
            "18%"

        3 ->
            "84%"

        4 ->
            "-4%"

        _ ->
            "-28%"


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
