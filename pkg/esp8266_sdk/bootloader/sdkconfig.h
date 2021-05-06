/*
 * Copyright (C) 2021 iosabi
 *
 * This file is subject to the terms and conditions of the GNU Lesser
 * General Public License v2.1. See the file LICENSE in the top level
 * directory for more details.
 */

/**
 * @ingroup     pkg_esp8266_sdk
 * @{
 *
 * @file
 * @brief       RIOT-OS modification of the bootloader SDK configuration
 *
 * The bootloader build of the ESP8266 SDK needs some settings from the SDK
 * configuration. These are normally generated by the menuconfig in the vendor
 * SDK.
 *
 * Some of these parameters are configurable by the application. For example,
 * the UART baudrate used by the console and the verbose level of the
 * bootloader.
 *
 * @author      iosabi <iosabi@protonmail.com>
 */

#ifndef ESP8266_SDK_BOOTLOADER_SDKCONFIG_H
#define ESP8266_SDK_BOOTLOADER_SDKCONFIG_H

#include "riotbuild.h"

#include "esp8266_idf_version.h"
#include "sdkconfig_default.h"

#if MODULE_ESP_LOG_COLORED
#define CONFIG_LOG_COLORS 1
#endif

/* SDK Log levels:
 *
 *  0 = NONE
 *  1 = ERROR
 *  2 = WARN
 *  3 = INFO
 *  4 = DEBUG
 *  5 = VERBOSE
 */
#if MODULE_ESP_LOG_STARTUP
#define CONFIG_LOG_BOOTLOADER_LEVEL 3 /* INFO */
#else
#define CONFIG_LOG_BOOTLOADER_LEVEL 0 /* NONE */
#endif

#if FLASH_MODE_QIO
#define CONFIG_FLASHMODE_QIO 1
#elif FLASH_MODE_QOUT
#define CONFIG_FLASHMODE_QOUT 1
#elif FLASH_MODE_DIO
#define CONFIG_FLASHMODE_DIO 1
#elif FLASH_MODE_DOUT
#define CONFIG_FLASHMODE_DOUT 1
#else
#error "Unknown flash mode selected."
#endif

#endif  /* ESP8266_SDK_BOOTLOADER_SDKCONFIG_H */
