module Test.Weft exposing (siteName, tests, weft)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, andMap, int, list, map, string)
import Json.Decode
import Json.Encode
import Ordt.Weft as Weft exposing (Weft)
import Test exposing (..)


tests : Test
tests =
    describe "Ordt.Weft Tests"
        [ emptyWeftTests
        , singletonWeftTests
        , encodingTests
        ]



-- FUZZERS


siteName : Fuzzer String
siteName =
    Fuzz.oneOf
        [ Fuzz.constant "Alice"
        , Fuzz.constant "Bob"
        , Fuzz.constant "Charlie"
        , Fuzz.constant "David"
        ]


weft : Fuzzer comparable -> Fuzzer (Weft comparable)
weft yarn =
    map
        (List.foldl identity Weft.empty)
        (list <| andMap int <| map Weft.insert yarn)



-- EMPTY


emptyWeftTests : Test
emptyWeftTests =
    describe "empty weft"
        [ fuzz siteName "empty weft always returns Maybe.Nothing" <|
            \yarnIdentifier ->
                Weft.empty
                    |> Weft.get yarnIdentifier
                    |> Expect.equal Nothing
        ]



-- SINGLETON


singletonWeftTests : Test
singletonWeftTests =
    describe "singleton weft"
        [ fuzz siteName "singleton weft returns Just where it needs" <|
            \fuzzedIdentifier ->
                let
                    w =
                        Weft.singleton "Alice" 1
                in
                Weft.get fuzzedIdentifier w
                    |> Expect.equal
                        (case fuzzedIdentifier of
                            "Alice" ->
                                Just 1

                            _ ->
                                Nothing
                        )
        ]



-- ENCODERS


encodingTests : Test
encodingTests =
    describe "encoding"
        [ fuzz (weft siteName) "round trip" <|
            \fuzzedWeft ->
                fuzzedWeft
                    |> Weft.encode Json.Encode.string
                    |> Json.Decode.decodeValue (Weft.decoder Json.Decode.string)
                    |> Expect.equal (Ok fuzzedWeft)
        ]
