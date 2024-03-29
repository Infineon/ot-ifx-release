#
#  Copyright (c) 2023, The OpenThread Authors.
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

set(HAL_DIR wpan-sdk/hal)
set(PAL_DIR wpan-sdk/pal)
set(PDL_DIR wpan-sdk/pdl)

# Add wpan-sdk library
add_library(infineon-wpan-sdk
    ${HAL_DIR}/source/platform_random.c
    ${HAL_DIR}/source/spar_setup.c
    ${HAL_DIR}/source/wiced_platform.c
    ${HAL_DIR}/source/wiced_platform_bt_cfg.c
    ${HAL_DIR}/source/wiced_platform_memory.c
    ${HAL_DIR}/source/wiced_platform_os.c
    ${PAL_DIR}/libc/platform_retarget_lock.c
    ${PAL_DIR}/libc/platform_stdio.c
    ${PAL_DIR}/mbedtls/source/aes_alt.c
    ${PAL_DIR}/mbedtls/source/ccm_alt.c
    ${PAL_DIR}/mbedtls/source/ecp_alt.c
    ${PAL_DIR}/mbedtls/source/platform_alt.c
    ${PAL_DIR}/mbedtls/source/sha256_alt.c
    ${PDL_DIR}/epa/platform_epa.c
    ${PDL_DIR}/led/platform_led.c
    ${PDL_DIR}/serial_flash/cy_serial_flash.c
)

# Add compile definitions for wpan-sdk
target_compile_definitions(infineon-wpan-sdk
    PRIVATE
        $<TARGET_PROPERTY:mbedtls,INTERFACE_COMPILE_DEFINITIONS>
        CY_PLATFORM_SWDCK=WICED_P02
        CY_PLATFORM_SWDIO=WICED_P03
        ENABLE_DEBUG=0
        SPAR_CRT_SETUP=spar_crt_setup
)

# Add include directories for wpan-sdk
target_include_directories(infineon-wpan-sdk
    PUBLIC
        ${HAL_DIR}/include
        ${PAL_DIR}/libc
        ${PAL_DIR}/mbedtls/include
        ${PDL_DIR}/epa
        ${PDL_DIR}/led
        ${PDL_DIR}/serial_flash
)

# Add include directory for openthread stack
target_include_directories(ot-config INTERFACE $<TARGET_PROPERTY:infineon-wpan-sdk,INTERFACE_INCLUDE_DIRECTORIES>)

# Add libraries used for wpan-sdk
target_link_libraries(infineon-wpan-sdk
    PRIVATE
        infineon-board-${IFX_BOARD}
        ot-config
)
