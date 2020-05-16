module Timespectre.Util exposing
    ( divisibleBy
    , isAfter
    , lastMidnight
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


lastMidnight : Time.Posix -> Time.Zone -> Time.Posix
lastMidnight now zone =
    Time.millisToPosix
        (Time.posixToMillis now
            - ((60 * 60 * 1000 * Time.toHour zone now)
                + (60 * 1000 * Time.toMinute zone now)
                + (1000 * Time.toSecond zone now)
              )
        )
