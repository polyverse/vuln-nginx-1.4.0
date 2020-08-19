#!/bin/bash
set -e

declare -r PV_DOCKER_REGISTRY="polyverse/vulnerable-nginx-1.4.0"
declare -r PV_GIT_COMMIT="$(git rev-parse --verify HEAD)"
declare -r PV_BASE_NAME="base"
declare -r PV_POLY_NAME="poly"

main() {
	build
	[ $? -ne 0 ] && return 1

	if [ "$1" == "-p" ]; then
		push
		[ $? -ne 0 ] && return 1
	fi

	return 0
}

push() {
	docker push "${PV_DOCKER_REGISTRY}:${PV_BASE_NAME}"
	docker push "${PV_DOCKER_REGISTRY}:${PV_BASE_NAME}-${PV_GIT_COMMIT}"
	docker push "${PV_DOCKER_REGISTRY}:${PV_POLY_NAME}-dev"
	docker push "${PV_DOCKER_REGISTRY}:${PV_POLY_NAME}-dev-${PV_GIT_COMMIT}"
	docker push "${PV_DOCKER_REGISTRY}:${PV_POLY_NAME}-rel"
	docker push "${PV_DOCKER_REGISTRY}:${PV_POLY_NAME}-rel-${PV_GIT_COMMIT}"
}

build() {
	declare -r PV_CFLAGS_BASE=""
	declare -r PV_CFLAGS_POLY="-fstack-protector-all -fno-omit-frame-pointer -finstrument-functions"
	declare -r PV_LFLAGS_BASE=""
	declare -r PV_LFLAGS_POLY="-Xlinker --emit-relocs"
	declare -r PV_CFLAGS_POLY_DEV="$PV_CFLAGS_POLY -Og -ggdb"
	declare -r PV_CFLAGS_POLY_REL="$PV_CFLAGS_POLY"

	# Build the (close to production) "base" image
	docker build \
		--build-arg PV_CFLAGS="${PV_CFLAGS_BASE}" \
		--build-arg PV_LFLAGS="${PV_LFLAGS_BASE}" \
		-t "${PV_DOCKER_REGISTRY}:${PV_BASE_NAME}" \
		-t "${PV_DOCKER_REGISTRY}:${PV_BASE_NAME}-${PV_GIT_COMMIT}" \
		.
	[ $? -ne 0 ] && return 1

	# Build the polyverse-ready "poly development image"
	docker build \
		--build-arg PV_CFLAGS="${PV_CFLAGS_POLY_DEV}" \
		--build-arg PV_LFLAGS="${PV_LFLAGS_POLY}" \
		-t "${PV_DOCKER_REGISTRY}:${PV_POLY_NAME}-dev" \
		-t "${PV_DOCKER_REGISTRY}:${PV_POLY_NAME}-dev-${PV_GIT_COMMIT}" \
		.
	[ $? -ne 0 ] && return 1

	# Build the polyverse-ready "poly release image"
	docker build  \
		--build-arg PV_CFLAGS="${PV_CFLAGS_POLY_REL}" \
		--build-arg PV_LFLAGS="${PV_LFLAGS_POLY}" \
		-t "${PV_DOCKER_REGISTRY}:${PV_POLY_NAME}-rel" \
		-t "${PV_DOCKER_REGISTRY}:${PV_POLY_NAME}-rel-${PV_GIT_COMMIT}" \
		.
	[ $? -ne 0 ] && return 1

	return 0
}


main "$@"
exit $?
