module Test.Weft exposing (tests)

import Expect exposing (Expectation)
import Json.Decode
import Json.Encode
import Ordt.Weft as Weft exposing (Weft)
import Test exposing (..)
import Test.Fuzz exposing (siteName)
import Test.Weft.Fuzz


tests : Test
tests =
    describe "Ordt.Weft Tests"
        [ emptyWeftTests
        , singletonWeftTests
        , encodingTests
        , equalityTests
        ]



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



-- EQUALITY


equalityTests : Test
equalityTests =
    describe "equality tests"
        [ test "wefts with different insertion order are equal" <|
            \_ ->
                let
                    left =
                        Weft.empty
                            |> Weft.insert "Alice" 1
                            |> Weft.insert "Bob" 2

                    right =
                        Weft.empty
                            |> Weft.insert "Bob" 2
                            |> Weft.insert "Alice" 1
                in
                Expect.equal left right
        ]



-- ENCODERS


encodingTests : Test
encodingTests =
    describe "encoding"
        [ fuzz (Test.Weft.Fuzz.weft siteName) "round trip" <|
            \fuzzedWeft ->
                fuzzedWeft
                    |> Weft.encode Json.Encode.string
                    |> Json.Decode.decodeValue (Weft.decoder Json.Decode.string)
                    |> Expect.equal (Ok fuzzedWeft)
        ]
