/*
 *  Copyright (c) 2023, The OpenThread Authors.
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *  3. Neither the name of the copyright holder nor the
 *     names of its contributors may be used to endorse or promote products
 *     derived from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 *  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 *  POSSIBILITY OF SUCH DAMAGE.
 */

/**
 * @file
 *   This file implements platform specific cryptography wrapper functions.
 */

#include <wiced_hal_platform.h>
#include <openthread/platform/crypto.h>

#ifndef CRYPTO_DEBUG
#define CRYPTO_DEBUG 0
#endif // CRYPTO_DEBUG

#if (CRYPTO_DEBUG != 0)
#define CRYPTO_TRACE(format, ...) printf(format, ##__VA_ARGS__)
#else
#define CRYPTO_TRACE(...)
#endif

void otPlatCryptoSystemInit(void)
{
    // This function is called to make this object to be linked.
}

void otPlatCryptoRandomInit(void) {}

void otPlatCryptoRandomDeinit(void) {}

otError otPlatCryptoRandomGet(uint8_t *aBuffer, uint16_t aSize)
{
    switch (wiced_hal_platform_random_get(aBuffer, aSize, NULL))
    {
    case WICED_SUCCESS:
        return OT_ERROR_NONE;
    case WICED_BADARG:
        return OT_ERROR_INVALID_ARGS;
    case WICED_NOT_AVAILABLE:
        return OT_ERROR_INVALID_STATE;
    default:
        return OT_ERROR_FAILED;
    }
}
