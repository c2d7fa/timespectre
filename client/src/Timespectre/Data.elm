module Timespectre.Data exposing (..)

import Random
import Time


type alias ActiveSession =
    Maybe Time.Posix


type alias Session =
    { id : String
    , start : Time.Posix
    , end : Time.Posix
    }


idGenerator : Random.Generator String
idGenerator =
    Random.list 6 (Random.int (Char.toCode 'a') (Char.toCode 'z'))
        |> Random.map (List.map Char.fromCode)
        |> Random.map String.fromList
