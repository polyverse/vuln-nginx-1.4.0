#!/bin/bash
set -e

# Enumerate the vendors in this file
VENDORS=('nginx')

function main() {
	VENDOR_ROOT="${PWD}/vendor"

	# Delete the whole vendor folder and make a clean one
	rm -rf ${VENDOR_ROOT} && mkdir -p "${VENDOR_ROOT}"

	# Upvendor each of the listed vendors
	for VENDOR in ${VENDORS[@]}; do
		upvendor $VENDOR
	done

	return 0
}

function upvendor() {
	VENDOR_FOLDER="${VENDOR_ROOT}/$1"
	mkdir -p "${VENDOR_FOLDER}"

	echo "INFO: Upvendoring: $1"
	cd ${VENDOR_FOLDER}
	$1
}

function nginx() {
	wget -nv "http://nginx.org/download/nginx-1.4.0.tar.gz"
}

main "$@"
exit $?
