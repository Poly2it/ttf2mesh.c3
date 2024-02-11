#!/bin/bash


# Copyright 2024 polybit
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


PROGRAM_NAME="$0"
PROGRAM_AUTHOR="polybit"
PROGRAM_VERSION="0.0.1"
PROGRAM_LOCATION="$(readlink -f "$(dirname $0)")"


usage() {
    echo -n "\
Usage: ${PROGRAM_NAME} [OPTIONS]...

  -h --help                  Display this information.
  -v --version               Display the program version.
  -d --install-dependencies  Update or install the dependencies.
  -e --build-examples        Build example projects.
"
}


version() {
    echo -n "\
${PROGRAM_NAME} ${PROGRAM_VERSION}
"
}


validate_ttf2mesh() {
    local PATH_SOURCE="$1"
    local PATH_STATIC_LIBRARIES="$2"
    local HAS_INTERNET_CONNECTION="$3"

    local VERSION_REMOTE="b767f3e"

    if [ -d "${PATH_SOURCE}" ]; then
        cd "${PATH_SOURCE}"

        local VERSION_LOCAL="$(git rev-parse --short HEAD)"
        
        if  ${HAS_INTERNET_CONNECTION} && [ "${VERSION_LOCAL}" != "${VERSION_REMOTE}" ]; then
            git fetch || exit 1
            git merge "${VERSION_REMOTE}" || exit 1
            git checkout "${VERSION_REMOTE}" || exit 1
        elif ${HAS_INTERNET_CONNECTION}; then
            echo "ttf2mesh up to date"
        else
            echo "Warning: Could not update ttf2mesh, no internet connection" 1>&2
        fi
    else
        if  ${HAS_INTERNET_CONNECTION}; then
            mkdir -p "${PATH_SOURCE}"
            cd "${PATH_SOURCE}"

            git clone "https://github.com/fetisov/ttf2mesh.git" "${PATH_SOURCE}" || exit 1
            git checkout "${VERSION_REMOTE}" || exit 1
        else
            echo "Error: No internet connection, could not clone remote dependency ttf2mesh." 1>&2
            exit 1
        fi
    fi

    if ! [ -e "${PATH_STATIC_LIBRARIES}/libttf2mesh.a" ] || [ "$(cat "${PATH_SOURCE}/BUILD_HASH")" != "${VERSION_REMOTE}" ]; then
        build_ttf2mesh "${PATH_SOURCE}" "${PATH_STATIC_LIBRARIES}"
    fi
}


build_ttf2mesh() {
    local PATH_SOURCE="$1"
    local PATH_STATIC_LIBRARIES="$2"

    local PATH_OUTPUT_STATIC_LIBRARY="${PATH_STATIC_LIBRARIES}/libttf2mesh.a"

    local CFLAGS="-ggdb -Wall -Wextra -pedantic -std=c99 -D_POSIX_C_SOURCE=199309L -O3"

    cd "${PATH_SOURCE}"
    mkdir -p "$(dirname "${PATH_OUTPUT_STATIC_LIBRARY}")"

    gcc ${CFLAGS} "ttf2mesh.c" "ttf2mesh.h" -c || exit 1
    ar rcs "${PATH_OUTPUT_STATIC_LIBRARY}" "ttf2mesh.o" || exit 1

    echo "$(git rev-parse --short HEAD)" > "${PATH_SOURCE}/BUILD_HASH"
}


validate_raylib_c3() {
    local PATH_SOURCE="$1"
    local HAS_INTERNET_CONNECTION="$2"

    local VERSION_REMOTE="d239f29"

    if [ -d "${PATH_SOURCE}" ]; then
        cd "${PATH_SOURCE}"

        local VERSION_LOCAL="$(git rev-parse --short HEAD)"
        
        if  ${HAS_INTERNET_CONNECTION} && [ "${VERSION_LOCAL}" != "${VERSION_REMOTE}" ]; then
            git fetch || exit 1
            git merge "${VERSION_REMOTE}" || exit 1
            git checkout "${VERSION_REMOTE}" || exit 1
        elif ${HAS_INTERNET_CONNECTION}; then
            echo "Raylib.c3 up to date"
        else
            echo "Warning: Could not update Raylib.c3, no internet connection" 1>&2
        fi
    else
        if  ${HAS_INTERNET_CONNECTION}; then
            mkdir -p "${PATH_SOURCE}"
            cd "${PATH_SOURCE}"

            git clone "https://github.com/Its-Kenta/Raylib.c3.git" "${PATH_SOURCE}" || exit 1
            git checkout "${VERSION_REMOTE}" || exit 1
        else
            echo "Error: No internet connection, could not clone remote dependency Raylib.c3." 1>&2
            exit 1
        fi
    fi
}


validate_raylib() {
    local PATH_SOURCE="$1"
    local PATH_STATIC_LIBRARIES="$2"
    local HAS_INTERNET_CONNECTION="$3"

    local VERSION_REMOTE="b600786c"

    if [ -d "${PATH_SOURCE}" ]; then
        cd "${PATH_SOURCE}"

        local VERSION_LOCAL="$(git rev-parse --short HEAD)"
        
        if  ${HAS_INTERNET_CONNECTION} && [ "${VERSION_LOCAL}" != "${VERSION_REMOTE}" ]; then
            git fetch || exit 1
            git merge "${VERSION_REMOTE}" || exit 1
            git checkout "${VERSION_REMOTE}" || exit 1
        elif ${HAS_INTERNET_CONNECTION}; then
            echo "raylib up to date"
        else
            echo "Warning: Could not update raylib, no internet connection" 1>&2
        fi
    else
        if  ${HAS_INTERNET_CONNECTION}; then
            mkdir -p "${PATH_SOURCE}"
            cd "${PATH_SOURCE}"

            git clone "https://github.com/raysan5/raylib.git" "${PATH_SOURCE}" || exit 1
            git checkout "${VERSION_REMOTE}" || exit 1
        else
            echo "Error: No internet connection, could not clone remote dependency raylib." 1>&2
            exit 1
        fi
    fi

    if ! [ -e "${PATH_STATIC_LIBRARIES}/libraylib.a" ] || [ "$(cat "${PATH_SOURCE}/BUILD_HASH")" != "${VERSION_REMOTE}" ]; then
        build_raylib "${PATH_SOURCE}" "${PATH_STATIC_LIBRARIES}"
    fi
}


build_raylib() {
    local PATH_SOURCE="$1"
    local PATH_STATIC_LIBRARIES="$2"

    local PATH_OUTPUT_STATIC_LIBRARY="${PATH_STATIC_LIBRARIES}/libraylib.a"
    mkdir -p "$(dirname "${PATH_OUTPUT_STATIC_LIBRARY}")"

    mkdir -p "${PATH_SOURCE}/build"
    cd "${PATH_SOURCE}/build"
    cmake .. || exit 1
    cmake --build . || exit 1

    cp "raylib/libraylib.a" "${PATH_OUTPUT_STATIC_LIBRARY}"

    echo "$(git rev-parse --short HEAD)" > "${PATH_SOURCE}/BUILD_HASH"
}


build_examples() {
    local WD="$1"
    local ENVIRONMENT="$2"
    local HAS_INTERNET_CONNECTION="$3"

    echo "building examples"
    mkdir -p "${WD}/examples/simple/lib"
    ln -srf "${WD}/ttf2mesh.c3l" "${WD}/examples/simple/lib/"
    
    local PATH_EXAMPLE="${WD}/examples/simple"
    local PATH_EXTERNAL="${WD}/external"
    validate_raylib_c3 "${PATH_EXTERNAL}/Raylib.c3" "${HAS_INTERNET_CONNECTION}"
    validate_raylib "${PATH_EXTERNAL}/raylib" "${PATH_EXTERNAL}/Raylib.c3/raylib.c3l/${ENVIRONMENT}" "${HAS_INTERNET_CONNECTION}"
    ln -srf "${PATH_EXTERNAL}/Raylib.c3/raylib.c3l" "${PATH_EXAMPLE}/lib/raylib.c3l"

    cd "${PATH_EXAMPLE}"
    c3c build
}


environment_name_get() {
    local KERNEL=$(uname -s)
    local ARCHITECTURE=$(uname -m)
    
    case "${KERNEL}:${ARCHITECTURE}:${OSTYPE}" in
        Linux:x86_64:*)   echo linux-x64 ;;
        Linux:arm64:*)    echo linux-aarch64 ;;
        Linux:riscv64:*)  echo linux-riscv64 ;;
        Linux:riscv32:*)  echo linux-riscv32 ;;
        Linux:i686:*)     echo linux-x86 ;;
        Darwin:x86_64:*)  echo macos-x64 ;;
        Darwin:arm64:*)   echo macos-aarch64 ;;
        FreeBSD:amd64:*)  echo freebsd-x64 ;;
        NetBSD:x86_64:*)  echo netbsd-x64 ;;
        OpenBSD:x86_64:*) echo openbsd-x64 ;;
        Windows:*)        echo windows-x64 ;;
        *)
            echo "Error: Unknown operating environment ${KERNEL} ${ARCHITECTURE} ${OSTYPE}" 1>&2
            exit 1
        ;;
    esac
}


arguments_parse() {
    local ARGS="$@"

    local OPTIONS_SHORT="$(string_whitespace_destroy "h,    v,       d,                    e")"
    local OPTIONS_LONG="$( string_whitespace_destroy "help, version, install-dependencies, build-examples")"
    local OPTIONS=$(getopt -o ${OPTIONS_SHORT} -l ${OPTIONS_LONG} -- "$ARGS")
    eval set -- "$OPTIONS"

    local OPTION_HELP=false
    local OPTION_VERSION=false
    local OPTION_INSTALL_DEPENDENCIES=false
    local OPTION_BUILD_EXAMPLES=false

    while true; do
        case "$1" in
            -h | --help)
                OPTION_HELP=true
                shift
                ;;
            -v | --version)
                OPTION_VERSION=true
                shift
                ;;
            -d | --install-dependencies)
                OPTION_INSTALL_DEPENDENCIES=true
                shift
                ;;
            -e | --build_examples)
                OPTION_BUILD_EXAMPLES=true
                shift
                ;;
            --)
                shift
                break
                ;;
            *)
                warn "invalid option: \$1"
                exit 1
                ;;
        esac
    done

    echo $OPTION_HELP
    echo $OPTION_VERSION
    echo $OPTION_INSTALL_DEPENDENCIES
    echo $OPTION_BUILD_EXAMPLES
}


string_whitespace_destroy() {
    echo -e "$@" | tr -d "[:space:]"
}


main() {
    local ARGS=($(arguments_parse "$@"))
    local OPTION_HELP=${ARGS[0]}
    local OPTION_VERSION=${ARGS[1]}
    local OPTION_INSTALL_DEPENDENCIES=${ARGS[2]}
    local OPTION_BUILD_EXAMPLES=${ARGS[3]}

    local WD="$(dirname "${PROGRAM_LOCATION}")"

    if $OPTION_HELP ||
        !( $OPTION_HELP || $OPTION_VERSION || $OPTION_INSTALL_DEPENDENCIES || $OPTION_BUILD_EXAMPLES )
    then
        usage
        exit 0
    fi

    if $OPTION_VERSION; then
        version
        exit 0
    fi

    # dns.mullvad.net
    local HAS_INTERNET_CONNECTION=$(
        ping -c 1 -W 1 194.242.2.2 >/dev/null
        if [ $? -eq 0 ]; then 
            echo true
        else
            echo false
        fi
    )
    local ENVIRONMENT="$(environment_name_get)"
    local PATH_EXTERNAL="${WD}/external"
    local PATH_STATIC_LIBRARIES="${WD}/ttf2mesh.c3l/${ENVIRONMENT}"

    if $OPTION_INSTALL_DEPENDENCIES; then
        validate_ttf2mesh "${PATH_EXTERNAL}/ttf2mesh" "${PATH_STATIC_LIBRARIES}" "${HAS_INTERNET_CONNECTION}"
        exit 0
    fi

    if $OPTION_BUILD_EXAMPLES; then
        validate_ttf2mesh "${PATH_EXTERNAL}/ttf2mesh" "${PATH_STATIC_LIBRARIES}" "${HAS_INTERNET_CONNECTION}"
        build_examples "${WD}" "${ENVIRONMENT}" "${HAS_INTERNET_CONNECTION}"
        exit 0
    fi
}


main "$@"

