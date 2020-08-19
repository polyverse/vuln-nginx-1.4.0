#!/bin/bash
set -e

declare -r PV_DOCKER_REGISTRY="507760724064.dkr.ecr.us-west-2.amazonaws.com"
declare -r PV_GIT_COMMIT="$(git rev-parse --verify HEAD)"
declare -r PV_BASE_NAME="base-nginx-1.4.0"
declare -r PV_POLY_NAME="poly-nginx-1.4.0"


main() {
        aws --region us-west-2 ecr get-login --no-include-email | bash -s
        [ $? -ne 0 ] && return 1

	# Push the "Production" base image
	push ${PV_BASE_NAME}
        [ $? -ne 0 ] && return 1

	# Push the "Polyverse Ready" dev image
	push ${PV_POLY_NAME}-dev
        [ $? -ne 0 ] && return 1

	# Push the "Polyverse Ready" rel image
	push ${PV_POLY_NAME}-rel
        [ $? -ne 0 ] && return 1

	return 0
}

push() {
	declare -r PV_NAME=${1}

        # create the repo; no harm if it already exists other than the call returns 255⏎
        aws --region us-west-2 ecr create-repository --repository-name ${PV_NAME} || true

	# Push "latest" (for convenience)
        docker push "$PV_DOCKER_REGISTRY/${PV_NAME}:latest"
        [ $? -ne 0 ] && return 1

	# Push tagged image
        docker push "$PV_DOCKER_REGISTRY/${PV_NAME}:${PV_GIT_COMMIT}"
        [ $? -ne 0 ] && return 1

        return 0
}

main "$@"
exit $?
