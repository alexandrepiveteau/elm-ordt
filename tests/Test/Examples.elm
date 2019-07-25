module Test.Examples exposing (tests)

import Expect exposing (Expectation)
import Test exposing (..)
import Test.Examples.Counter as Counter exposing (Counter)


tests : Test
tests =
    describe "end-to-end examples tests"
        [ counterTests
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
