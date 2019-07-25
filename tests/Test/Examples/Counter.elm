module Test.Examples.Counter exposing
    ( Counter, CounterOperation(..)
    , zero, increment, decrement
    , fromWeave, toWeave
    , value
    )

{-| An example counter using the work-in-progress Ordt.Weave API of the package
`alexandrepiveteau/elm-ordt`, that simply records each operation as an increment or a decrement to a
global variable.


# Counters

@docs Counter, CounterOperation

# Build

@docs zero, increment, decrement


# Weaves

@docs fromWeave, toWeave

#Query

@docs value

-}

import Ordt.Weave as Weave exposing (Weave)
import Ordt.Weft as Weft exposing (Weft)
import Set exposing (Set)



-- COUNTERS


type CounterOperation
    = Decrement
    | Increment


type Counter comparable
    = Counter_built_in (Weave comparable CounterOperation)



-- insertInPair : ( a, b ) -> ( Set a, Set b ) -> ( Set a, Set b )


insertInPair ( x, y ) ( xs, ys ) =
    Tuple.pair (Set.insert x xs) (Set.insert y ys)



-- BUILD


{-| Creates a new empty counter.
-}
zero : Counter comparable
zero =
    Counter_built_in Weave.empty


{-| Integrates a given operation into a counter, without adding any explicit dependencies.
-}
integrate : comparable -> CounterOperation -> Counter comparable -> Counter comparable
integrate site operation (Counter_built_in weave) =
    let
        newWeave =
            Weave.push site operation Set.empty weave
    in
    Counter_built_in newWeave


increment : comparable -> Counter comparable -> Counter comparable
increment site counter =
    integrate site Increment counter


decrement : comparable -> Counter comparable -> Counter comparable
decrement site counter =
    integrate site Decrement counter



-- WEAVES


fromWeave : Weave comparable CounterOperation -> Counter comparable
fromWeave weave =
    Counter_built_in weave


toWeave : Counter comparable -> Weave comparable CounterOperation
toWeave (Counter_built_in weave) =
    weave



-- QUERY


{-| Performs one step of accumulating a `CounterOperation` into an `Int` value. When applied
repeatedly, this function can reduce a whole weave of operations.

Note that for this counter we do not care at all about the previous steps when performing this
accumulation.

-}
step : Weft s -> CounterOperation -> Int -> Int
step _ operation acc =
    case operation of
        Decrement ->
            acc - 1

        Increment ->
            acc + 1


{-| Evaluate the current values of this counter.
-}
value : Counter comparable -> Int
value (Counter_built_in weave) =
    Weave.foldl
        step
        0
        weave
