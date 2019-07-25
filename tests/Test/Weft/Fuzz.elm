module Test.Weft.Fuzz exposing (weft)

import Fuzz exposing (Fuzzer, andMap, int, list, map)
import Ordt.Weft as Weft exposing (Weft)


{-| Creates a `Fuzzer` for a `Weft` that will return a potentially non-empty `Weft`.
-}
weft : Fuzzer comparable -> Fuzzer (Weft comparable)
weft yarn =
    map
        (List.foldl identity Weft.empty)
        (list <| andMap int <| map Weft.insert yarn)
