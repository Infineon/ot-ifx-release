#
#  Copyright (c) 2021, The OpenThread Authors.
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  3. Neither the name of the copyright holder nor the
#     names of its contributors may be used to endorse or promote products
#     derived from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.
#

cmake_minimum_required(VERSION 3.15.3)
project(ot-ifx VERSION 0.2.0)

message(STATUS "CMAKE_TOOLCHAIN_FILE: ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "PROJECT_BINARY_DIR: ${PROJECT_BINARY_DIR}")
message(STATUS "CMAKE_CURRENT_SOURCE_DIR: ${CMAKE_CURRENT_SOURCE_DIR}")
message(STATUS "IFX_PLATFORM: ${IFX_PLATFORM}")
message(STATUS "IFX_CHIPSET: ${IFX_CHIPSET}")
message(STATUS "PROJECT_SOURCE_DIR: ${PROJECT_SOURCE_DIR}")
message(STATUS "CMAKE_DEBUG_TARGET_PROPERTIES: ${CMAKE_DEBUG_TARGET_PROPERTIES}")

string(TOUPPER ${IFX_CHIPSET} IFX_CHIPSET_UPPERCASE)

# Set required platform library for openthread stack
set(OT_PLATFORM_LIB_FTD "openthread-${IFX_PLATFORM}")
set(OT_PLATFORM_LIB_MTD ${OT_PLATFORM_LIB_FTD})
set(OT_PLATFORM_LIB ${OT_PLATFORM_LIB_FTD})

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)

option(VERBOSE "Enable verbose message" OFF)

# Add openthread SDK.
add_subdirectory(openthread)

# Add compile option for openthread stack
target_compile_definitions(
    ot-config
    INTERFACE
    OPENTHREAD_CONFIG_PLATFORM_ASSERT_MANAGEMENT
    OPENTHREAD_CONFIG_IP6_MAX_EXT_MCAST_ADDRS=3
)

# Add include directory for openthread stack
target_include_directories(
    ot-config
    INTERFACE
    src/${IFX_PLATFORM}
)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -Wshadow")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wshadow -fno-exceptions")

# Add the target executable with the specified platform and board information
include("${PROJECT_SOURCE_DIR}/third_party/infineon/platform/${IFX_PLATFORM}/${IFX_PLATFORM}.cmake")

# Add Platform Abstraction Layer (used by OpenThread stack)
add_subdirectory(src/${IFX_PLATFORM})

# Add third party information, ex. platform and board
add_subdirectory(third_party)

# Disable building the default openthread executables
set(OT_BUILD_EXECUTABLES OFF)

set(APP_INC_DIRS ${PROJECT_SOURCE_DIR}/openthread/examples/platforms)

if(OT_APP_CLI)
    file(
        GLOB
            APP_SOURCES
        LIST_DIRECTORIES
            false
        CONFIGURE_DEPENDS
            ${PROJECT_SOURCE_DIR}/openthread/examples/apps/cli/*.c
            ${PROJECT_SOURCE_DIR}/openthread/examples/apps/cli/*.cpp
    )

    if(OT_FTD)
        set(APP_LINK_LIBS
            openthread-cli-ftd
            openthread-ftd
            ${OT_PLATFORM_LIB_FTD}
            ${OT_MBEDTLS}
            ot-config
        )

        add_example_target(
            "${APP_SOURCES}"
            "${APP_INC_DIRS}"
            "${APP_LINK_LIBS}"
            cli
            ftd
        )
    endif()

    if(OT_MTD)
        set(APP_LINK_LIBS
            openthread-cli-mtd
            openthread-mtd
            ${OT_PLATFORM_LIB_MTD}
            ${OT_MBEDTLS}
            ot-config
        )

        add_example_target(
            "${APP_SOURCES}"
            "${APP_INC_DIRS}"
            "${APP_LINK_LIBS}"
            cli
            mtd
        )
    endif()

elseif(OT_APP_NCP)
    file(
        GLOB
            APP_SOURCES
        LIST_DIRECTORIES
            false
        CONFIGURE_DEPENDS
            ${PROJECT_SOURCE_DIR}/openthread/examples/apps/ncp/*.c
            ${PROJECT_SOURCE_DIR}/openthread/examples/apps/ncp/*.cpp
    )

    if(OT_FTD)
        set(APP_LINK_LIBS
            openthread-ncp-ftd
            openthread-ftd
            ${OT_PLATFORM_LIB_FTD}
            ${OT_MBEDTLS}
            ot-config
        )

        add_example_target(
            "${APP_SOURCES}"
            "${APP_INC_DIRS}"
            "${APP_LINK_LIBS}"
            ncp
            ftd
        )
    endif()

    if(OT_MTD)
        set(APP_LINK_LIBS
            openthread-ncp-mtd
            openthread-mtd
            ${OT_PLATFORM_LIB_MTD}
            ${OT_MBEDTLS}
            ot-config
        )

        add_example_target(
            "${APP_SOURCES}"
            "${APP_INC_DIRS}"
            "${APP_LINK_LIBS}"
            ncp
            mtd
        )
    endif()

elseif(OT_APP_RCP)
    file(
        GLOB
            APP_SOURCES
        LIST_DIRECTORIES
            false
        CONFIGURE_DEPENDS
            ${PROJECT_SOURCE_DIR}/openthread/examples/apps/ncp/*.c
            ${PROJECT_SOURCE_DIR}/openthread/examples/apps/ncp/*.cpp
    )

    set(APP_LINK_LIBS
        openthread-rcp
        openthread-radio
        ${OT_PLATFORM_LIB}
        ot-config
    )

    add_example_target(
        "${APP_SOURCES}"
        "${APP_INC_DIRS}"
        "${APP_LINK_LIBS}"
        rcp
     )

endif()
