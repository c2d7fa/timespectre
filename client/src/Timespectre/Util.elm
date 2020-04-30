module Timespectre.Util exposing
    ( divisibleBy
    , isAfter
    , rangeBy
    )

import Time


rangeBy : Int -> Int -> Int -> List Int
rangeBy start end skip =
    if start > end then
        []

    else
        start :: rangeBy (start + skip) end skip


divisibleBy : Int -> Int -> Bool
divisibleBy n x =
    modBy n x == 0


isAfter : Time.Posix -> Time.Posix -> Bool
isAfter b a =
    Time.posixToMillis b <= Time.posixToMillis a
