module Main exposing (tests)

import Test exposing (Test, describe)
import Test.Examples as Examples
import Test.Weave as Weave
import Test.Weft as Weft


tests : Test
tests =
    describe "ORDTs Library Tests"
        [ Weave.tests
        , Weft.tests
        , Examples.tests
        ]
