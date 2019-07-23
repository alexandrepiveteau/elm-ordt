module Ordt.Weft exposing
    ( Weft
    , empty, singleton, insert, remove
    , get, compare
    , joinLower, joinUpper
    , fromDict, toDict
    , encode, decoder
    )

{-| Wefts are like vector clocks – they offer causality information across different events in a
distributed system. A new weft is `empty`. Each site is then associated with an index, indicating
the index of the last operation received for that particular site.

For any two instances of `Weft`, an upper bound as well as a lower bound can be found. The lower
bound is the last known state to both wefts. The upper bound is the minimal state that could know
both wefts. This ability to find an upper or/and a lower bound is often referred to as a
[semi-lattice](https://en.wikipedia.org/wiki/Semilattice).

Usually, these clocks are associated with some operations. There is, in general, no guarantee that
a specific instance of weft is associated to an operation though.

To manage the operation indices for any site, use the `get` and `insert` functions.

The site identifiers can be any comparable type. This includes `Int`, `Float`, `Time`, `Char`,
`String`, and tuples or lists of comparable types.


# Wefts

@docs Weft


# Build

@docs empty, singleton, insert, remove


# Query

@docs get, compare


# Semi-lattice

@docs joinLower, joinUpper


# Dicts

@docs fromDict, toDict


# Encoders

@docs encode, decoder

-}

import Dict exposing (Dict)
import Json.Decode as D
import Json.Encode as E



-- TYPES


{-| Represents a weft in a distributed system. So `Weft (Int)` means that each site is identified by
an `Int`, and `Weft (String)` that each site is identified by a `String`.
-}
type Weft comparable
    = Weft_built_in (Dict comparable Int)



-- BUILD


{-| Create a baseline that will always act as a proper lower bound for all the possible instances
of an `Ordt.Weft`.

    -- joinLower clock empty == empty
    -- joinUpper clock empty == clock



-}
empty : Weft comparable
empty =
    Weft_built_in Dict.empty


{-| Create a weft that will contain only a single index for a given site.

    -- joinLower (singleton "Alice" 1) empty == empty
    -- joinUpper (singleton "Alice" 1) empty == singleton "Alice" 1



-}
singleton : comparable -> Int -> Weft comparable
singleton yarn index =
    Weft_built_in (Dict.singleton yarn index)


{-| Set the last operation index for a certain yarn.
-}
insert : comparable -> Int -> Weft comparable -> Weft comparable
insert yarn index (Weft_built_in dict) =
    Weft_built_in (Dict.insert yarn index dict)


{-| Remove a yarn from a weft. If the key is not found, no changes are made.
-}
remove : comparable -> Weft comparable -> Weft comparable
remove yarn (Weft_built_in dict) =
    Weft_built_in (Dict.remove yarn dict)


{-| Turn a weft into a `Dict`.
-}
toDict : Weft comparable -> Dict comparable Int
toDict (Weft_built_in dict) =
    dict


{-| Turn a `Dict` into a weft.
-}
fromDict : Dict comparable Int -> Weft comparable
fromDict dict =
    Weft_built_in dict



-- QUERY


{-| Get the last operation index for a certain site.
-}
get : comparable -> Weft comparable -> Maybe Int
get yarn (Weft_built_in dict) =
    Dict.get yarn dict


{-| Compare any two `Weft` instances. This comparison takes in consideration that two wefts might
not be comparable, in which case `Order.EQ` will be returned.


    alice =
        insert "Alice 3" empty

    bob =
        insert "Bob" 2 empty

    -- compare empty alice == Order.LT
    -- compare empty empty == Order.EQ
    -- compare alice bob == Order.EQ
    -- compare bob empty == Order.GT

-}
compare : Weft comparable -> Weft comparable -> Order
compare (Weft_built_in weave) (Weft_built_in to) =
    let
        strictSubset a b =
            Dict.toList a
                |> List.map (\( k, v ) -> ( k, v, Dict.get k b ))
                |> List.filterMap
                    (\( k, v1, m ) ->
                        Maybe.map
                            (\v2 ->
                                ( v1, v2 )
                            )
                            m
                    )
                |> List.all (\( v1, v2 ) -> v1 <= v2)

        lhsSmaller =
            strictSubset weave to

        rhsSmaller =
            strictSubset to weave
    in
    case ( lhsSmaller, rhsSmaller ) of
        ( True, True ) ->
            EQ

        ( False, False ) ->
            EQ

        ( True, False ) ->
            LT

        ( False, True ) ->
            GT



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



-- ENCODERS


{-| Turn a `Weft` into a JSON value.
-}
encode : (comparable -> E.Value) -> Weft comparable -> E.Value
encode yarnEncode (Weft_built_in dict) =
    Dict.toList dict
        |> List.map (\( yarn, index ) -> ( yarnEncode yarn, E.int index ))
        |> List.map (\( yarn, index ) -> E.object [ ( "yarn", yarn ), ( "index", index ) ])
        |> E.list identity


{-| Decode a JSON value into a `Weft`.
-}
decoder : D.Decoder comparable -> D.Decoder (Weft comparable)
decoder yarnDecoder =
    D.list
        (D.map2
            Tuple.pair
            (D.field "yarn" yarnDecoder)
            (D.field "index" D.int)
        )
        |> D.map Dict.fromList
        |> D.map Weft_built_in
