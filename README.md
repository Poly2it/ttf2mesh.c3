# ttf2mesh.c3 - [ttf2mesh](https://github.com/fetisov/ttf2mesh) bindings for the [C3 Programming Language](https://c3-lang.org/)

1. [Overview](#overview)
2. [Installation](#installation)
    1. [Compatability](#compatability)

## Overview

This project provides C3 bindings for the ttf2mesh C library.

## Installation

Clone this repository into your project's `external/` directory. To automatically install
and compile the project dependencies, run `./scripts/setup.sh -d` in this project's root
directory.

Include the headers themselves by linking the c3l directory to your `lib/` directory. As
an example: `ln -sr external/ttf2mesh.c3/ttf2mesh.c3l/ lib/ttf2mesh.c3l`.

### Compatability

The process of building the ttf2mesh library will vary depending on platform, but
assuming you are able to build it, ttf2mesh.c3 should work on the platforms specified
below:

| Platform       | Status            |
|----------------|-------------------|
| Linux          | Supported         |
| MacOS          | Assumed, untested |
| Windows (MSYS) | Assumed, untested |
| Most others    | Assumed, untested |

---

Copyright 2024 polybit.
See the attached LICENSE file for the full terms of this project.

