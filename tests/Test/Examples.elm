module Test.Examples exposing (tests)

import Expect exposing (Expectation)
import Set
import Test exposing (..)
import Test.Examples.Counter as Counter exposing (Counter)
import Test.Examples.GSet as GSet exposing (GSet)


tests : Test
tests =
    describe "end-to-end examples tests"
        [ counterTests
        , setTests
        ]


counterTests : Test
counterTests =
    describe "counter tests"
        [ test "empty counter has size 0" <|
            \_ ->
                Counter.zero
                    |> Counter.value
                    |> Expect.equal 0
        , test "single site counter increments properly" <|
            \_ ->
                Counter.zero
                    |> Counter.increment "Alice"
                    |> Counter.increment "Alice"
                    |> Counter.increment "Alice"
                    |> Counter.value
                    |> Expect.equal 3
        , test "single site counter decrements properly" <|
            \_ ->
                Counter.zero
                    |> Counter.decrement "Alice"
                    |> Counter.decrement "Alice"
                    |> Counter.value
                    |> Expect.equal -2
        , test "multiple sites counter increments properly" <|
            \_ ->
                Counter.zero
                    |> Counter.increment "Alice"
                    |> Counter.increment "Bob"
                    |> Counter.increment "Alice"
                    |> Counter.increment "Zoe"
                    |> Counter.value
                    |> Expect.equal 4
        , test "multiple sites counter increments and decrements properly" <|
            \_ ->
                Counter.zero
                    |> Counter.increment "Alice"
                    |> Counter.decrement "Bob"
                    |> Counter.decrement "Zoe"
                    |> Counter.decrement "Bob"
                    |> Counter.increment "Alice"
                    |> Counter.value
                    |> Expect.equal -1
        ]


setTests : Test
setTests =
    describe "set tests"
        [ test "empty set has no elements" <|
            \_ ->
                GSet.empty
                    |> GSet.value
                    |> Set.size
                    |> Expect.equal 0
        , test "single site set adds enough items" <|
            \_ ->
                let
                    set =
                        GSet.empty
                            |> GSet.insert "Alice" "Hello"
                            |> GSet.insert "Alice" "World"
                            |> GSet.value
                in
                Expect.equal 2 (Set.size set)
        ]
