module Timespectre.Model exposing (..)

import Time
import Timespectre.Data exposing (..)


type alias Model =
    { sessions : List Session
    , active : ActiveSession
    }


type Msg
    = StartSession
    | EndSession


init : () -> ( Model, Cmd Msg )
init () =
    ( { sessions =
            [ { start = Time.millisToPosix 1586977440000, end = Time.millisToPosix 1586980560000 }
            , { start = Time.millisToPosix 1586997440000, end = Time.millisToPosix 1586999560000 }
            ]
      , active = Nothing
      }
    , Cmd.none
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update msg model =
    ( case msg of
        StartSession ->
            model

        EndSession ->
            model
    , Cmd.none
    )
