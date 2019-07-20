module ORDT.Weft exposing
    ( Weft
    , empty
    , getSiteIndex
    , insertSiteIndex
    , joinLower
    , joinUpper
    )

{-| Wefts are like vector clocks - they offer causality information across different events in a
distributed system. A new weft is `empty`. Each site is then associated with an index, indicating
the index of the last operation received for that particular site.

For any two instances of `Weft`, an upper bound as well as a lower bound can be found. The lower
bound is the last known state to both wefts. The upper bound is the minimal state that could know
both wefts. This ability to find upper or/and a lower bound is often referred to as a
[semi-lattice](https://en.wikipedia.org/wiki/Semilattice).

Usually, these clocks are associated with some operations. There is, in general, no guarantee that
a specific instance of weft is associated to a operation.


# Types

@docs Weft


# Primitives

@docs empty


# Contents

@docs getSiteIndex
@docs insertSiteIndex


# Semi-lattice

@docs joinLower
@docs joinUpper

-}

import Dict exposing (Dict)



-- VECTOR CLOCK


{-| Represents a weft in a distributed system. So `Weft (Int)` means that each site is identified by
an `Int`, and `Weft (String)` that each site is identified by a `String`.
-}
type Weft comparable
    = Weft_built_in (Dict comparable Int)



-- CONSTRUCTION


{-| Create a baseline that will always act as a proper lower bound for all the possible instances
of an `EchoWeft`.

    joinLower clock empty == empty

    joinUpper clock empty == clock

-}
empty : Weft comparable
empty =
    Weft_built_in Dict.empty



-- SITE INDEX UPDATES


{-| Get the last operation index for a certain site.
-}
getSiteIndex : comparable -> Weft comparable -> Maybe Int
getSiteIndex site (Weft_built_in dict) =
    Dict.get site dict


{-| Set the last operation index for a certain site.
-}
insertSiteIndex : comparable -> Int -> Weft comparable -> Weft comparable
insertSiteIndex site index (Weft_built_in dict) =
    Weft_built_in (Dict.insert site index dict)



-- SEMI-LATTICE


{-| Perform a semi-lattice join on the lower bound of the two wefts.
-}
joinLower : Weft comparable -> Weft comparable -> Weft comparable
joinLower (Weft_built_in a) (Weft_built_in b) =
    let
        dictionary =
            Dict.merge
                (\_ _ -> identity)
                (\k v1 v2 -> Dict.insert k (min v1 v2))
                (\_ _ -> identity)
                a
                b
                Dict.empty
    in
    Weft_built_in dictionary


{-| Perform a semi-lattice join on the upper bound of the two wefts.
-}
joinUpper : Weft comparable -> Weft comparable -> Weft comparable
joinUpper (Weft_built_in a) (Weft_built_in b) =
    let
        dictionary =
            Dict.merge
                (\k v1 -> Dict.insert k v1)
                (\k v1 v2 -> Dict.insert k (max v1 v2))
                (\k v2 -> Dict.insert k v2)
                a
                b
                Dict.empty
    in
    Weft_built_in dictionary
