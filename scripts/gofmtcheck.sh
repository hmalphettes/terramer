#!/usr/bin/env bash
# Source: https://github.com/hashicorp/terraform/blob/master/scripts/gofmtcheck.sh

# Check gofmt
echo "==> Checking that code complies with gofmt requirements..."
#shellcheck disable=SC2046
gofmt_files=$(gofmt -l $(find . -name '*.go' | grep -v vendor))
if [[ -n ${gofmt_files} ]]; then
    echo 'gofmt needs running on the following files:'
    echo "${gofmt_files}"
    echo "You can use the command: \`make fmt\` to reformat code."
    exit 1
fi

exit 0
