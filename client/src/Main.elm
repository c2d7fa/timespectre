module Main exposing (main)

import Browser
import Timespectre.Model exposing (init, subscriptions, update)
import Timespectre.View exposing (view)


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
