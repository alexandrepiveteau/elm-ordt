module Main exposing (tests)

import Test exposing (Test, describe)
import Test.Examples.Counter
import Test.Weave as Weave exposing (tests)
import Test.Weft as Weft exposing (tests)


tests : Test
tests =
    describe "ORDTs Library Tests"
        [ Weave.tests
        , Weft.tests
        ]
