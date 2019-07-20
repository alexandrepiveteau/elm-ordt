# ORDTs

Systems are synchronous. The world is distributed. Data and computations must be designed in a way
that allows them to be replicated, and converge even if some they happen concurrently.

There has been a lot of research recently on **commutative replicated data types**. These types
offer some **strong eventual consistency** guarantees, which can be very convenient in distributed
systems. Most of the research is dedicated to finding new designs for common data structures, which
often do not offer the expressiveness required by some business use-cases.

**Operational Replicated Data Types** help solve this issue by considering the **operations** that
sites want to achieve in the distributed system. Rather than focusing on **data**, this type focuses
on **intent** by asking sites to **explicitly encode their operations**. It then offers multiple
utilities to manage this data.

The naming conventions, and important parts of this library are inspired by the paper
[Deep Hypertext with Embedded Revision Control Implemented in Regular Expressions](https://dl.acm.org/citation.cfm?id=1832777)
from Victor Grishchenko.

## What's included ?

For the moment, **not much**. You'll find a basic implementation of an `ORDT.Weft`, which is
nothing more than a [vector clock](https://en.wikipedia.org/wiki/Vector_clock). In the future, the
following elements should be included :

- A fully featured `ORDT.Weave` with support for folding, merging and efficient operation insertion.
- Instances of `Json.Decoder` and `Json.Encoder` for `ORDT.Weft` and `ORDT.Weave`. This will be
  handy when sharing data across sites.
- (Optional) Some wrappers around `ORDT.Weave` to implement some common replicated data types, like
  sets, sequences or counters.

## Should I contribute ?

If you find a bug (or fix one), sure ! If you want to change the API, ideas are welcome, but I tend
to be a bit conservative and can't promise we will include your fancy-does-everything-API right away
in this library.