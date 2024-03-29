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

set(TOOLS_DIR ${PROJECT_SOURCE_DIR}/third_party/infineon/btsdk-tools)
if(CMAKE_HOST_APPLE)
    set(TOOLS_DIR ${TOOLS_DIR}/OSX)
elseif(CMAKE_HOST_WIN32)
    set(TOOLS_DIR ${TOOLS_DIR}/Windows)
else()
    set(TOOLS_DIR ${TOOLS_DIR}/Linux64)
endif()

set(BASELIB_DIR ${PROJECT_SOURCE_DIR}/third_party/infineon/platform/${IFX_PLATFORM}/${IFX_CHIPSET}/COMPONENT_${IFX_CHIPSET_UPPERCASE})

string(REPLACE "-" "_" PATCH_DIR ${IFX_BOARD})
string(TOUPPER ${PATCH_DIR} PATCH_DIR)
set(PATCH_DIR ${BASELIB_DIR}/internal/${IFX_CHIPSET_UPPERCASE}/patches_${PATCH_DIR})

set(PLATFORM_DIR ${BASELIB_DIR}/platforms)
set(SCRIPTS_DIR ${PROJECT_SOURCE_DIR}/third_party/infineon/platform/${IFX_PLATFORM}/scripts)
set(PATCH_SYMBOLS ${PATCH_DIR}/patch.sym)
set(BTP ${PLATFORM_DIR}/flash.btp)
set(LIB_INSTALLER_C generated/${IFX_CHIPSET_UPPERCASE}/lib_installer.c)
set(HDF_FILE ${BASELIB_DIR}/internal/${IFX_CHIPSET_UPPERCASE}/configdef${IFX_CHIPSET_UPPERCASE}.hdf)

set(LINKER_DEFINES
    FLASH0_BEGIN_ADDR=0x00500000
    FLASH0_LENGTH=0x00100000
    XIP_DS_OFFSET=0x00014000
    XIP_LEN=0x00068000
    SRAM_BEGIN_ADDR=0x00200000
    SRAM_LENGTH=0x00070000
    AON_AREA_END=0x00284000
    ISTATIC_BEGIN=0x500C00
    ISTATIC_LEN=0x400
    NUM_PATCH_ENTRIES=256
    BTP=${BTP}
)

set(CGS_LIST
    ${PATCH_DIR}/patch.cgs
    ${PLATFORM_DIR}/platform.cgs
    ${PLATFORM_DIR}/platform_xip.cgs
)

function(add_example_target)
    set(APP_SOURCES ${ARGV0})
    set(APP_INC_DIRS ${ARGV1})
    set(APP_LINK_LIBS ${ARGV2})
    set(APP_TYPE ${ARGV3})
    set(DEVICE_TYPE ${ARGV4})

    set(TARGET_NAME ${APP_TYPE})
    set(RUNTIME_OUTPUT_DIRECTORY bin)
    set(RUNTIME_OUTPUT_NAME ${APP_TYPE})

    if(DEVICE_TYPE)
        set(TARGET_NAME ${TARGET_NAME}-${DEVICE_TYPE})
        set(RUNTIME_OUTPUT_DIRECTORY ${RUNTIME_OUTPUT_DIRECTORY}/${DEVICE_TYPE})
    endif()

    set(LD_FILE ${RUNTIME_OUTPUT_DIRECTORY}/${RUNTIME_OUTPUT_NAME}.ld)
    set(MAP_FILE ${RUNTIME_OUTPUT_DIRECTORY}/${RUNTIME_OUTPUT_NAME}.map)

    add_executable(${TARGET_NAME}
        ${APP_SOURCES}
        ${LIB_INSTALLER_C}
    )

    set_property(TARGET ${TARGET_NAME} PROPERTY RUNTIME_OUTPUT_DIRECTORY ${RUNTIME_OUTPUT_DIRECTORY})
    set_property(TARGET ${TARGET_NAME} PROPERTY RUNTIME_OUTPUT_NAME ${RUNTIME_OUTPUT_NAME})
    set_property(TARGET ${TARGET_NAME} PROPERTY SUFFIX .elf)

    target_include_directories(${TARGET_NAME}
        PRIVATE
        ${APP_INC_DIRS}
    )

    add_custom_command(
                        OUTPUT
                            ${LIB_INSTALLER_C}
                        COMMAND
                            bash --norc --noprofile
                            ${SCRIPTS_DIR}/bt_gen_lib_installer.bash
                            --scripts=${SCRIPTS_DIR}
                            --out=${LIB_INSTALLER_C}
                            $<$<BOOL:${VERBOSE}>:--verbose>
                      )

    add_custom_command(
                        TARGET
                            ${TARGET_NAME}
                        PRE_LINK
                        COMMAND
                            pwd
                        COMMAND
                            bash --norc --noprofile
                            ${SCRIPTS_DIR}/bt_pre_build.bash
                            --scripts=${SCRIPTS_DIR}
                            --defs="${LINKER_DEFINES}"
                            --ld=${LD_FILE}
                            --patch=${PATCH_SYMBOLS}
                            $<$<BOOL:${VERBOSE}>:--verbose>
                        WORKING_DIRECTORY
                            ${CMAKE_CURRENT_BINARY_DIR}
                      )

    target_link_libraries(
                            ${TARGET_NAME}
                            PRIVATE
                                ${APP_LINK_LIBS}
                            -Wl,--whole-archive
                            infineon-board-${IFX_BOARD}
                            infineon-wpan-sdk
                            -Wl,--no-whole-archive
                            -T${LD_FILE}
                            -Wl,--cref
                            -Wl,--entry=spar_crt_setup
                            -Wl,--gc-sections
                            -Wl,--just-symbols=${PATCH_SYMBOLS}
                            -Wl,--warn-common
                            -Wl,-Map=${MAP_FILE}
                            -nostartfiles
                         )

    add_custom_command(
                        TARGET
                            ${TARGET_NAME}
                        POST_BUILD
                        COMMAND
                            ${CMAKE_COMMAND} -E env PATH="$ENV{PATH}:${GCC_BIN_DIR}"
                            bash --norc --noprofile
                            ${SCRIPTS_DIR}/bt_post_build.bash
                            --scripts=${SCRIPTS_DIR}
                            --cross="arm-none-eabi-"
                            --tools=${TOOLS_DIR}
                            --builddir=$<TARGET_FILE_DIR:${TARGET_NAME}>
                            --elfname=$<TARGET_FILE_NAME:${TARGET_NAME}>
                            --appname=${RUNTIME_OUTPUT_NAME}
                            --appver=0x00000000
                            --hdf=${BASELIB_DIR}/internal/${IFX_CHIPSET_UPPERCASE}/configdef${IFX_CHIPSET_UPPERCASE}.hdf
                            --entry=spar_crt_setup.entry
                            --cgslist="${CGS_LIST}"
                            --cgsargs="-O DLConfigBD_ADDRBase:default"
                            --btp=${BTP}
                            --id=${PLATFORM_DIR}/IDFILE.txt
                            --overridebaudfile=${PLATFORM_DIR}/BAUDRATEFILE.txt
                            --chip=20739B2
                            --minidriver=${PLATFORM_DIR}/minidriver.hex
                            --clflags=-NOHCIRESET
                            --extras=static_config_XIP_
                            $<$<BOOL:${VERBOSE}>:--verbose>
                        WORKING_DIRECTORY
                            ${CMAKE_CURRENT_BINARY_DIR}
    )
endfunction()
