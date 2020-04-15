module Timespectre.Data exposing (..)

import Time


type alias ActiveSession =
    Maybe Time.Posix


type alias Session =
    { start : Time.Posix
    , end : Time.Posix
    }
