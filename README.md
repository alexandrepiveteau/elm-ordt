# Operational Replicated Data Types for Elm

![Elm package](https://img.shields.io/elm-package/v/alexandrepiveteau/elm-ordt)
[![Build Status](https://travis-ci.com/alexandrepiveteau/elm-ordt.svg?branch=develop)](https://travis-ci.com/alexandrepiveteau/elm-ordt)

Systems are asynchronous and distributed. Data and computations must be designed in a way that
allows them to be replicated, and converge even if events are concurrent.

There has recently been a lot of industry interest on the academical topic **commutative replicated
data types**. These types offer some **strong eventual consistency** guarantees, which can be very
convenient in distributed systems. A lot of research is dedicated to finding new implementations for
common data structures, which often do not offer the expressiveness required by some business
use-cases.

**Operational Replicated Data Types** help solve this issue by considering the **operations** that
sites want to achieve in the distributed system. Rather than focusing on **content**, this
data structure focuses on **intent** by asking sites to **explicitly encode their operations**. It
then offers multiple utilities to manage this data.

The naming conventions, and important parts of this library are inspired by the paper
[Deep Hypertext with Embedded Revision Control Implemented in Regular Expressions](https://dl.acm.org/citation.cfm?id=1832777)
from Victor Grishchenko.


## What's included ?

You'll find **two primary data structures** in this library. An `Ordt.Weft` is there to let you 
represent a current timestamp in a distributed system. It contains information about **what you know 
from each site**. An `Ordt.Weave` represents a **site-specific knowledge of the distributed system
as a whole**. It contains all the events that this site is aware of.

In fact, an `Ordt.Weft` is nothing more than a [vector clock](https://en.wikipedia.org/wiki/Vector_clock),
whereas an `Ordt.Weave` is just a fancy `Dict` associating `Ordt.Weft` to domain-specific 
operations.

For each of these data structures, you'll also find some `encode : Json.Encode.Value` and
`decoder : Json.Decode.Decoder` functions, that will let you exchange information across
different sites (for instance through some `Http` requests).

## Weft, weave, yarns ? What are those ?

This nomenclature is taken from [Deep Hypertext with Embedded Revision Control Implemented in Regular Expressions](https://dl.acm.org/citation.cfm?id=1832777)
by Victor Grishchenko.

- A **yarn** designates the history of a single site in our ORDT.
- A **weave** designates the history of the distributed system as a whole. Pay attention though, not
  everyone is necessarily aware of the same things, so when you build a `Ordt.Weave`, it always 
  corresponds to **what a specific site thinks the whole state is**.
- A **weft** is a timestamp in a **weave**. There's no absolute ordering for wefts, only a partial
  ordering. For example, a participant Alice could be aware of something that Bob does not yet know
  about, and Bob could also know about something else that Alice does not yet know about, all of
  this at the same time.

## How can I use this library ?

Run `elm install alexandrepiveteau/elm-ordt` in your project and you're good to go !

There are some examples of what the library could be used for available in the [examples folder](tests/Test/Examples/).
Make sure to check them out :)

I also recommend you to read the [official documentation](https://package.elm-lang.org/packages/alexandrepiveteau/elm-ordt/latest/)
available on the **Elm package manager**.


## Should I contribute ?

Yes ! This package is very new, and its design very experimental. I would love to get some
feedback on the API design, bug fixes or help improving the overall performance of the data
structures.
