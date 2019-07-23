module Ordt.Weave exposing
    ( Weave, defaultIndex
    , empty, singleton, push
    , isEmpty, size, yarn, weft
    , map, foldl, foldr, filter, filterMap
    , merge
    , encode, decoder
    )

{-| Weaves are collections specifically designed to handle wefts and operations. They keep causality
information about events in a distributed system, and offer some methods to replicate, `merge` and
edit parts of the history.

The site identifiers can be any comparable type. This includes `Int`, `Float`, `Time`, `Char`,
`String`, and tuples or lists of comparable types.


# Weaves

@docs Weave, defaultIndex


# Build

@docs empty, singleton, push


# Query

@docs isEmpty, size, yarn, weft


# Transform

@docs map, foldl, foldr, filter, filterMap

# Combine

@docs merge


# Encoders

@docs encode, decoder

-}

import AlgebraicGraph.Graph as Graph exposing (Graph)
import Dict exposing (Dict)
import Json.Decode as D
import Json.Encode as E
import Ordt.Weft as Weft exposing (Weft)
import Set exposing (Set)



-- WEAVES


type alias Yarn site o =
    List
        { index : Int
        , operation : o
        , direct : Weft site
        , transitive : Weft site
        }


{-| Represents a weave of operations. Each operation has some extra information about knowledge it
had from other sites when it was integrated.
-}
type Weave comparable o
    = Weave_built_in (Dict comparable (Yarn comparable o))


{-| Default index when writing an operation.

Indices could be set to smaller than this, but for all the methods that require the insertion of a
new operation at the start of a yarn, this is the index that will be used.

-}
defaultIndex : Int
defaultIndex =
    0



-- BUILD


{-| Create a weave that will indicate that no events have occured yet in the distributed system.

    -- size empty == 0
    -- isEmpty empty == True



-}
empty : Weave comparable o
empty =
    Weave_built_in Dict.empty


{-| Create a weave that will contain only a single operation, with no dependencies and knowledge of
the rest of the weave.

    -- size singleton "Alice" "Hello" == 1



-}
singleton : comparable -> o -> Weave comparable o
singleton site operation =
    let
        atom =
            { index = defaultIndex
            , operation = operation
            , direct = Weft.empty
            , transitive = Weft.empty
            }
    in
    Weave_built_in (Dict.singleton site (List.singleton atom))


{-| Append an operation to a certain site, and indicate with a `Dict` the operations that are
explicitly ackowledged by this push.

**This is not for arbitrary insertions in the past !**

This function appends your operation **at the end** of the yarn you specify.

Internally, some implicit references will be added if necessary, for transitive acknowledgements or
acknowledgements of the previous operations of this site. If you add at a certain `site`, the index
for this particular site will use `max(get weft site, nextWeaveIndexFor site)`.

An important note - you can not reference the future in an operation you're adding now. Indeed, this
could otherwise lead to some pretty severe inconsitencies - what if you reference the future of your
friend, and he references yours ? You don't have a directed acyclic graph anymore !

    type CounterOperation
        = Increment
        | Decrement

    ack =
        Weft.singleton "Alice" Weave.defaultIndex

    weave =
        Weave.empty
            |> Weave.push "Alice" Increment Weft.empty
            |> Weave.push "Bob" Decrement Weft.empty
            |> Weave.push "Charlie" Increment ack

-}
push :
    comparable
    -> o
    -> Set comparable
    -> Weave comparable o
    -> Weave comparable o
push site op dependencies (Weave_built_in dict) =
    let
        siteNextIndex =
            Dict.get site dict
                |> Maybe.withDefault []
                |> List.head
                |> Maybe.map .index
                |> Maybe.map ((+) 1)
                |> Maybe.withDefault defaultIndex

        currentWeft =
            weft (Weave_built_in dict)

        siteWeft =
            Weft.singleton site siteNextIndex

        -- TODO : Fold over the acknowledged sites + indices here.
        -- Weft.joinUpper siteWeft acknowledgedWeft
        directWeft =
            Debug.todo "Not implemented yet."

        transitiveWeft =
            Debug.todo "Not implemented yet."

        atom =
            { index = siteNextIndex
            , operation = op
            , direct = directWeft
            , transitive = transitiveWeft
            }

        updatedYarn =
            Dict.get site dict
                |> Maybe.withDefault []
                |> (::) atom

        updatedDict =
            Dict.insert site updatedYarn dict
    in
    Weave_built_in updatedDict



-- TRANSFORM


{-| Used internally to perform different operations. Uses the `Weft.compare` method to create a
partial order of the elements.
-}
topologicalSort :
    Weave comparable o
    ->
        List
            { yarn : comparable
            , index : Int
            , operation : o
            , direct : Weft comparable
            , transitive : Weft comparable
            }
topologicalSort weave =
    Debug.todo "Not implemented yet."


{-| Reduce the topologically sorted operations of a weave, starting with the most recent one.


    type Operation
        = Increment
        | Decrement

    acc weft op count =
        case op of
            Increment ->
                count + 1

            Decrement ->
                count - 1

    -- foldr acc 0 (Weave.singleton "Alice" Increment) == 1

-}
foldl :
    (Weft comparable -> o -> b -> b)
    -> b
    -> Weave comparable o
    -> b
foldl f acc weave =
    let
        reduce element a =
            f element.transitive element.operation a
    in
    weave
        |> topologicalSort
        |> List.foldl reduce acc


{-| Reduce the topologically sorted operations of a weave, starting with the oldest one.


    type GrowableSetOperation a
        = AddValue a

    acc weft op (SetValue v) =
        Set.insert v acc

    -- foldl acc Set.empty (Weave.singleton "Alice" (AddValue 3)) == Set.singleton 3

-}
foldr :
    (Weft comparable -> o -> b -> b)
    -> b
    -> Weave comparable o
    -> b
foldr f acc weave =
    let
        reduce element a =
            f element.transitive element.operation a
    in
    weave
        |> topologicalSort
        |> List.foldr reduce acc


{-| Map a function onto a weave, creating a weave with transformed operations.
-}
map : (Weft comparable -> a -> b) -> Weave comparable a -> Weave comparable b
map isGood weave =
    filterMap
        (\w e -> Just (isGood w e))
        weave


{-| Keep operations that satisfy the test.
-}
filter :
    (Weft comparable -> o -> Bool)
    -> Weave comparable o
    -> Weave comparable o
filter isGood weave =
    filterMap
        (\w e ->
            if isGood w e then
                Just e

            else
                Nothing
        )
        weave


{-| Filter out certain operations. For example, you might want to exclude some unnecessary or
illegal operations from the weave.
-}
filterMap : (Weft comparable -> a -> Maybe b) -> Weave comparable a -> Weave comparable b
filterMap isGood (Weave_built_in dicts) =
    let
        wrap atom op =
            { index = atom.index
            , operation = op
            , direct = atom.direct
            , transitive = atom.transitive
            }

        filterMapYarn =
            List.filterMap (\atom -> Maybe.map (wrap atom) (isGood atom.transitive atom.operation))
    in
    Weave_built_in (Dict.map (\_ -> filterMapYarn) dicts)


{-| The most general way to combine two weaves. You provide three accumulators for when an
operation with a given `Weft` gets combined:

1.  Only in the left `Weave`.
2.  In both `Weave`.
3.  Only in the right `Weave`.

-}
merge :
    (Weft comparable -> o -> result -> result)
    -> (Weft comparable -> o -> o -> result -> result)
    -> (Weft comparable -> o -> result -> result)
    -> Weave comparable o
    -> Weave comparable o
    -> result
    -> result
merge left both right l r =
    Debug.todo "Not implemented yet."



-- QUERY


{-| Determine if a weave is empty.
-}
isEmpty : Weave comparable o -> Bool
isEmpty weave =
    size weave == 0


{-| Determine the number of operations in this weave.
-}
size : Weave comparable o -> Int
size (Weave_built_in dict) =
    Dict.values dict
        |> List.map List.length
        |> List.foldl (+) 0


{-| Get the yarn associated with a certain site identifier.
-}
yarn : comparable -> Weave comparable o -> List o
yarn identifier (Weave_built_in dict) =
    Dict.get identifier dict
        |> Maybe.withDefault []
        |> List.map (\atom -> atom.operation)


{-| Get the weft representing the knowledge that this weave has of the whole distributed system.
This does not necessarily mean that this weave has access to all the prior operations though, as
some site-specific garbage collection might have occured.
-}
weft : Weave comparable o -> Weft comparable
weft (Weave_built_in dict) =
    Dict.map (\_ y -> List.head y) dict
        |> Dict.toList
        |> List.filterMap (\( k, m ) -> Maybe.map (\a -> ( k, a.index )) m)
        |> List.foldl
            (\( i, y ) -> Weft.insert i y)
            Weft.empty



-- ENCODERS


{-| Turn a `Weave` into a JSON value.
-}
encode : (comparable -> E.Value) -> (o -> E.Value) -> Weave comparable o -> E.Value
encode =
    Debug.todo "Not implemented yet."


{-| Decode a JSON value into a `Weave`.
-}
decoder : D.Decoder comparable -> D.Decoder o -> D.Decoder (Weave comparable o)
decoder =
    Debug.todo "Not implemented yet."
