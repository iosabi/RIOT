#!/bin/bash

# Script to update the bootloader.inc.mk file.
#
# bootloader.inc.mk contains the list of source files and config options that
# the vendor SDK uses while building the bootloader. This is generated and
# included in the RIOT-OS source repository since it requires to have both a
# native toolchain and esp8266 toolchain configured and it was in general tricky
# to get to work from RIOT-OS build system.

SCRIPTDIR=$(dirname $(realpath "$0"))

set -eu

main() {
  if ! which xtensa-esp8266-elf-gcc >/dev/null; then
    echo "Assuming xtensa-esp8266-elf-gcc from /opt/esp/xtensa-esp8266-elf/bin"
    export PATH="/opt/esp/xtensa-esp8266-elf/bin:${PATH}"
  fi

  local bldr_dir="${SCRIPTDIR}/bldr_build"
  rm -rf "${bldr_dir}"
  mkdir -p "${bldr_dir}"
  cd "${bldr_dir}"

  local sdk_path=$(realpath "${SCRIPTDIR}/../../../build/pkg/esp8266_sdk")
  if [[ ! -e "${sdk_path}/Kconfig" ]]; then
    echo "Download the ESP8266 RTOS SDK to ${sdk_path} by building RIOT first"
    exit 1
  fi

  # Builds the bootloader.bin with the default config into the bldr_build
  PROJECT_NAME=bootloader PROJECT_PATH="${bldr_dir}" \
  make \
    -f "${sdk_path}/make/project.mk" IDF_PATH="${sdk_path}" \
    CONFIG_TOOLPREFIX=xtensa-esp8266-elf- \
    defconfig bootloader -j

  # List of all the sources and headers used by the build except the generated
  # sdkconfig.h.
  local bootloader_srcs=(
    $(find -name '*.d' | xargs cat | tr ' ' '\n' | grep -E '^/[^ ]+\.[ch]$' -o |
        xargs -I {} realpath {} | grep -v -F /sdkconfig.h | sort | uniq))

  (
    echo "# Generated by ./update_mk.sh, don't modify directly."
    echo
    # List of source files (.c)
    echo "ESP_SDK_BOOTLOADER_SRCS = \\"
    local src
    for src in "${bootloader_srcs[@]}"; do
      if [[ "${src%.c}" != "${src}" ]]; then
        echo "  ${src#${sdk_path}/} \\"
      fi
    done
    echo "  #"
    echo
  ) >"${SCRIPTDIR}/bootloader.inc.mk"

  # List of the relevant CONFIG_ settings used by those files.
  local configs=(
    $(grep -h -o -E '\bCONFIG_[A-Z0-9_]+\b' "${bootloader_srcs[@]}" |
      sort | uniq))

  (
    echo "/* Generated by ./update_mk.sh, don't modify directly."
    echo " * Default CONFIG_ parameters from the SDK package."
    echo " */"
    echo
    # Only list those configs not in the bootloader sdkconfig.h included in
    # RIOT-OS.
    local conf
    for conf in "${configs[@]}"; do
      grep -F "#define ${conf} " "${SCRIPTDIR}/sdkconfig.h" >/dev/null ||
      grep -F "#define ${conf} " "${bldr_dir}/build/include/sdkconfig.h" || true
    done
    echo
  ) >"${SCRIPTDIR}/sdkconfig_default.h"

  echo "Done."
}

main "$@"
