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

# Add platform base library
add_library(infineon-base-${IFX_PLATFORM} INTERFACE)

# Add include directory for platform base library
target_include_directories(
                            infineon-base-${IFX_PLATFORM}
                            INTERFACE
                                ${IFX_CHIPSET}/COMPONENT_${IFX_CHIPSET_UPPERCASE}/include
                                ${IFX_CHIPSET}/COMPONENT_${IFX_CHIPSET_UPPERCASE}/include/hal
                                ${IFX_CHIPSET}/COMPONENT_${IFX_CHIPSET_UPPERCASE}/include/internal
                                ${IFX_CHIPSET}/COMPONENT_${IFX_CHIPSET_UPPERCASE}/include/stack
                                ${IFX_CHIPSET}/COMPONENT_${IFX_CHIPSET_UPPERCASE}/internal/${IFX_CHIPSET_UPPERCASE}
                          )

# Add include directory for openthread stack
target_include_directories(ot-config INTERFACE $<TARGET_PROPERTY:infineon-base-${IFX_PLATFORM},INTERFACE_INCLUDE_DIRECTORIES>)

# Add compile option for platform base library
target_compile_options(
                        infineon-base-${IFX_PLATFORM}
                        INTERFACE
                            @${CMAKE_CURRENT_SOURCE_DIR}/${IFX_CHIPSET}/COMPONENT_${IFX_CHIPSET_UPPERCASE}/internal/${IFX_CHIPSET_UPPERCASE}/gcc/${IFX_CHIPSET_UPPERCASE}.cflag
                      )

# Add platform board library
add_subdirectory(bsp)
