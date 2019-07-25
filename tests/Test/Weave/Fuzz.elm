module Test.Weave.Fuzz exposing (weave)

import Fuzz exposing (Fuzzer, andMap, list, map)
import Ordt.Weave as Weave exposing (Weave)
import Set


{-| Create a valid `Fuzzer` for a `Weave` that will return some potentially non-empty weaves.
-}
weave : Fuzzer comparable -> Fuzzer operation -> Fuzzer (Weave comparable operation)
weave yarn operation =
    map (List.foldl identity Weave.empty)
        (list <| andMap (Fuzz.constant Set.empty) <| andMap operation <| map Weave.push yarn)
