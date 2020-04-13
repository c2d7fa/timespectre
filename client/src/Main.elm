module Main exposing (..)

import Browser
import Html exposing (Html, button, div, span, text)
import Html.Events exposing (onClick)
import Http


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Model
    = Value Int
    | Loading


init : () -> ( Model, Cmd Msg )
init () =
    ( Loading, Http.get { url = "/api/counter", expect = Http.expectString Received } )


type Msg
    = Increment
    | Decrement
    | Received (Result Http.Error String)
    | Posted (Result Http.Error ())


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update msg model =
    case ( msg, model ) of
        ( Received result, _ ) ->
            case result of
                Ok s ->
                    case String.toInt s of
                        Just n ->
                            ( Value n, Cmd.none )

                        Nothing ->
                            ( Loading, Cmd.none )

                _ ->
                    ( Loading, Cmd.none )

        ( _, Loading ) ->
            ( Loading, Cmd.none )

        ( Increment, Value n ) ->
            ( Value (n + 1), Http.post { url = "/api/counter/increment", body = Http.emptyBody, expect = Http.expectWhatever Posted } )

        ( Decrement, Value n ) ->
            ( Value (n - 1), Http.post { url = "/api/counter/decrement", body = Http.emptyBody, expect = Http.expectWhatever Posted } )

        ( Posted _, _ ) ->
            ( model, Cmd.none )


view model =
    case model of
        Loading ->
            text "Loading..."

        Value n ->
            div []
                [ text (String.fromInt n)
                , button [ onClick Increment ] [ text "Increment" ]
                , button [ onClick Decrement ] [ text "Decrement" ]
                ]
