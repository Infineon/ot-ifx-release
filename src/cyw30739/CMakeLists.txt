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

# Add compile options for openthread stack
target_compile_definitions(
                            ot-config
                            INTERFACE
                                MBEDTLS_AES_ALT
                                MBEDTLS_CCM_ALT
                                MBEDTLS_CHECK_PARAMS
                                MBEDTLS_CHECK_PARAMS_ASSERT
                                MBEDTLS_ECP_ALT
                                MBEDTLS_PLATFORM_SETUP_TEARDOWN_ALT
                                MBEDTLS_SHA256_ALT
                                OPENTHREAD_CONFIG_FILE="openthread-core-${IFX_PLATFORM}-config.h"
                                OPENTHREAD_CONFIG_PLATFORM_ASSERT_MANAGEMENT
                                OPENTHREAD_PROJECT_CORE_CONFIG_FILE="openthread-core-${IFX_PLATFORM}-config.h"
                          )

if(OT_APP_CLI)
# Add platform library
add_library(
                openthread-${IFX_PLATFORM}
                alarm.c
                crypto.c
                entropy.c
                ifx_ot_cli_cmd.c
                logging.c
                misc.c
                radio.c
                radio_wrapper.cpp
                settings.c
                system.c
                uart.c
                ${PROJECT_SOURCE_DIR}/openthread/examples/platforms/utils/link_metrics.cpp
                ${PROJECT_SOURCE_DIR}/openthread/examples/platforms/utils/mac_frame.cpp
            )

# Add compile options for platform library
target_compile_definitions(
                            openthread-${IFX_PLATFORM}
                            PRIVATE
                                CLI_COMMAND_SEPARATOR
                                IFX_CLI_COMMAND=0
                                IFX_CLI_COMMAND_SERIAL_FLASH=0
                                PACKET_STATISTICS=0
                          )

elseif(OT_APP_NCP OR OT_APP_RCP)

# Add platform library
add_library(
                openthread-${IFX_PLATFORM}
                alarm.c
                crypto.c
                entropy.c
                logging.c
                misc.c
                radio.c
                radio_wrapper.cpp
                settings.c
                system.c
                uart.c
                ${PROJECT_SOURCE_DIR}/openthread/examples/platforms/utils/link_metrics.cpp
                ${PROJECT_SOURCE_DIR}/openthread/examples/platforms/utils/mac_frame.cpp
            )

# Add compile options for platform library
if (OT_APP_RCP)
# RCP
target_compile_definitions(
                            openthread-${IFX_PLATFORM}
                            PRIVATE
                                PACKET_STATISTICS=0
                                OPENTHREAD_CONFIG_MAC_CSL_RECEIVER_ENABLE=0
                                SERIAL_FLASH=0
                          )
else()
# NCP
target_compile_definitions(
                            openthread-${IFX_PLATFORM}
                            PRIVATE
                                PACKET_STATISTICS=0
                                SERIAL_FLASH=0
                          )
endif()
endif()

if(I15DOT4_IEEE_EUI64)
    target_compile_definitions(
                                openthread-${IFX_PLATFORM}
                                PRIVATE
                                    I15DOT4_IEEE_EUI64="${I15DOT4_IEEE_EUI64}")
endif()

# Add include directory for platform library
target_include_directories(
                            openthread-${IFX_PLATFORM}
                            PRIVATE
                                ${OT_PUBLIC_INCLUDES}
                                ${PROJECT_SOURCE_DIR}/openthread/examples/platforms
                          )

# Add libraries used for generating platform library
target_link_libraries(
                        openthread-${IFX_PLATFORM}
                        PRIVATE
                            ot-config
                            infineon-board-${IFX_BOARD}
)
