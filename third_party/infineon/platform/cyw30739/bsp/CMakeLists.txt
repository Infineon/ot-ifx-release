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

set(BOARD_CONFIG_SOURCES
    cycfg.c
    cycfg_pins.c
)

set(DESIGN_MODUS ${CMAKE_CURRENT_SOURCE_DIR}/${IFX_BOARD}/design.modus)

string(TOUPPER ${IFX_BOARD} BOARD_DIR)
string(PREPEND BOARD_DIR ${IFX_BOARD}/TARGET_)

add_custom_command(
    OUTPUT ${BOARD_CONFIG_SOURCES}
    COMMAND ${MTB_TOOLS_DIR}/device-configurator/device-configurator-cli
        --output-dir
        ${CMAKE_CURRENT_BINARY_DIR}
        --library
        ${BASELIB_DIR}/devicesupport.xml
        --build
        ${DESIGN_MODUS}
        --readonly
    DEPENDS
        ${BASELIB_DIR}/devicesupport.xml
        ${DESIGN_MODUS}
)

add_library(infineon-board-${IFX_BOARD}
    ${BOARD_CONFIG_SOURCES}
)

# Add compile option for platform board library
target_compile_definitions(
    infineon-board-${IFX_BOARD}
    PUBLIC
)

# Add include directory for platform board library
target_include_directories(
    infineon-board-${IFX_BOARD}
    PUBLIC
        ${BOARD_DIR}
        ${CMAKE_CURRENT_BINARY_DIR}
        ${PROJECT_SOURCE_DIR}/third_party/infineon/btsdk-include
)

# Set the dependency between platform board library and platform base library
target_link_libraries(
    infineon-board-${IFX_BOARD}
    PRIVATE
        infineon-base-${IFX_PLATFORM}
)
