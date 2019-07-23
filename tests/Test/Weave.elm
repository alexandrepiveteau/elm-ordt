module Test.Weave exposing (tests)

import Dict exposing (Dict)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Ordt.Weave as Weave exposing (Weave)
import Ordt.Weft as Weft exposing (Weft)
import Set exposing (Set)
import Test exposing (..)
import Test.Weft exposing (siteName)


tests : Test
tests =
    describe "Ordt.Weave Tests"
        [ emptyWeave
        , singletonWeave
        , pushWeave
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
