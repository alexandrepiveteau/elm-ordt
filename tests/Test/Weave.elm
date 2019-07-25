module Test.Weave exposing (tests)

import Expect exposing (Expectation)
import Json.Decode
import Json.Encode
import Ordt.Weave as Weave exposing (Weave)
import Ordt.Weft as Weft exposing (Weft)
import Set exposing (Set)
import Test exposing (..)
import Test.Fuzz exposing (operation, siteName)
import Test.Weave.Fuzz


tests : Test
tests =
    describe "Ordt.Weave Tests"
        [ emptyWeave
        , singletonWeave
        , pushWeave
        , encodingTests
        ]



-- EMPTY


emptyWeave : Test
emptyWeave =
    describe "empty weave"
        [ test "Weave.empty has size 0" <|
            \_ ->
                Weave.empty
                    |> Weave.size
                    |> Expect.equal 0
        , test "Weave.empty isEmpty" <|
            \_ ->
                Weave.empty
                    |> Weave.isEmpty
                    |> Expect.true "isEmpty should be true"
        , fuzz siteName "Weave.empty has empty yarns" <|
            \fuzzedIdentifier ->
                Weave.empty
                    |> Weave.yarn fuzzedIdentifier
                    |> Expect.equal []
        , test "Weave.empty has empty weft" <|
            \_ ->
                Weave.empty
                    |> Weave.weft
                    |> Expect.equal Weft.empty
        ]



-- SINGLETON


singletonWeave : Test
singletonWeave =
    describe "singleton weave"
        [ test "Weave.singleton has size 1" <|
            \_ ->
                Weave.singleton "Alice" ()
                    |> Weave.size
                    |> Expect.equal 1
        , test "Weave.singleton isEmpty is False" <|
            \_ ->
                Weave.singleton "Bob" ()
                    |> Weave.isEmpty
                    |> Expect.false "isEmpty should be false"
        , test "Weave.singleton has singleton weft" <|
            \_ ->
                Weave.singleton "Alice" ()
                    |> Weave.weft
                    |> Expect.equal (Weft.singleton "Alice" Weave.defaultIndex)
        , describe "yarn tests"
            [ test "Weave.singleton has non-empty yarn" <|
                \_ ->
                    Weave.singleton "Bob" ()
                        |> Weave.yarn "Bob"
                        |> Expect.equal [ () ]
            , test "Weave.singleton has empty yarn" <|
                \_ ->
                    Weave.singleton "Bob" ()
                        |> Weave.yarn "Alice"
                        |> Expect.equal []
            ]
        ]



-- PUSH


pushWeave : Test
pushWeave =
    describe "push weave"
        [ test "empty with push has size 1" <|
            \_ ->
                Weave.empty
                    |> Weave.push "Alice" () Set.empty
                    |> Weave.size
                    |> Expect.equal 1
        , test "push 4 times has size 4" <|
            \_ ->
                Weave.empty
                    |> Weave.push "Alice" () Set.empty
                    |> Weave.push "Bob" () Set.empty
                    |> Weave.push "Alice" () Set.empty
                    |> Weave.push "Charles" () Set.empty
                    |> Weave.size
                    |> Expect.equal 4
        ]



-- ENCODERS


encodingTests : Test
encodingTests =
    describe "encoding"
        [ fuzz (Test.Weave.Fuzz.weave siteName operation) "round trip" <|
            \fuzzedWeave ->
                fuzzedWeave
                    |> Weave.encode Json.Encode.string Json.Encode.string
                    |> Json.Decode.decodeValue (Weave.decoder Json.Decode.string Json.Decode.string)
                    |> Expect.equal (Ok fuzzedWeave)
        ]
