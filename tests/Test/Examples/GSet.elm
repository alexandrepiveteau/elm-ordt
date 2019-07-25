module Test.Examples.GSet exposing
    ( GSet, GSetOperation(..)
    , empty, insert
    , fromWeave, toWeave
    , value
    )

{-| An example set using the work-in-progress Ordt.Weave API of the package `alexandrepiveteau/elm-ordt`, that simply
inserts each operation forever in a grow-only set.


# Counters

@docs GSet, GSetOperation

# Build

@docs empty, insert


# Weaves

@docs fromWeave, toWeave

#Query

@docs value

-}

import Ordt.Weave as Weave exposing (Weave)
import Ordt.Weft exposing (Weft)
import Set as CoreSet



-- SETS


type GSetOperation comparable
    = Insert comparable


type GSet site comparable
    = Set_built_in (Weave site (GSetOperation comparable))


empty : GSet comparableA comparableB
empty =
    Set_built_in Weave.empty


integrate : comparableA -> GSetOperation comparableB -> GSet comparableA comparableB -> GSet comparableA comparableB
integrate site operation (Set_built_in weave) =
    let
        newWeave =
            Weave.push site operation CoreSet.empty weave
    in
    Set_built_in newWeave


insert : comparableA -> comparableB -> GSet comparableA comparableB -> GSet comparableA comparableB
insert site element weave =
    integrate site (Insert element) weave



-- WEAVES


fromWeave : Weave comparableA (GSetOperation comparableB) -> GSet comparableA comparableB
fromWeave weave =
    Set_built_in weave


toWeave : GSet comparableA comparableB -> Weave comparableA (GSetOperation comparableB)
toWeave (Set_built_in weave) =
    weave



-- QUERY


{-| Performs one step of accumulating a `SetOperation` into a core `Set` value. When applied
repeatedly, this function can reduce a whole weave of operations.

Note that for this set we do not care at all about the previous steps when performing this
accumulation.

-}
step : Weft comparableA -> GSetOperation comparableB -> CoreSet.Set comparableB -> CoreSet.Set comparableB
step _ operation acc =
    case operation of
        Insert element ->
            CoreSet.insert element acc


{-| Evaluate the current elements of this set.
-}
value : GSet comparableA comparableB -> CoreSet.Set comparableB
value (Set_built_in weave) =
    Weave.foldl
        step
        CoreSet.empty
        weave
