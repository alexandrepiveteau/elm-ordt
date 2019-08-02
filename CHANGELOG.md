# Changelog

## Upcoming

* **Minor**
    * Combination utilities for `Ordt.Weave`.
    * More granular insertions for `Ordt.Weave` than with `push`.
* **Patch**
    * More efficient implementation of `Ordt.Weave`.
    * Index-based Json encoding and decoding for `Ordt.Weft`.
    
## Released

* 2.1.2
    * **Fix** : `Weave.push` does not do transitive dependencies for the branch to which it is added.
* 2.1.0
    * **Improvement**: Some `encode` and `decoder` functions for `Ordt.Weave`.
* 2.0.0
    * **Breaking change**: Namespace changed from `ORDT` to `Ordt`.
    * **Breaking change**: The function `Ordt.Weft.getSiteAtIndex` is simplified to `Ordt.Weft.get`
        and the function `Ordt.Weft.insertSiteAtIndex` is simplified to `Ordt.Weft.insert`.
    * **New**: An `Ordt.Weave` data type for history tracking.
    * **Improvement**: Some `encode` and `decoder` functions for `Ordt.Weft`.
    * **Improvement**: Some `fromDict` and `toDict` functions for `Ordt.Weft`.
    * **Improvement**: A `compare` function for `Ordt.Weft`.
* 1.0.0 – Initial release with basic `ORDT.Weft` support.