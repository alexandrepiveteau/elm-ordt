module Test.Fuzz exposing (operation, siteName)

-- FUZZERS

import Fuzz exposing (Fuzzer)


siteName : Fuzzer String
siteName =
    Fuzz.oneOf
        [ Fuzz.constant "Alice"
        , Fuzz.constant "Bob"
        , Fuzz.constant "Charlie"
        , Fuzz.constant "David"
        ]


operation : Fuzzer String
operation =
    Fuzz.oneOf
        [ Fuzz.constant "Increment"
        , Fuzz.constant "Decrement"
        ]
