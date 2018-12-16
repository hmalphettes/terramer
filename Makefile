TEST?=./...
GOFMT_FILES?=$$(find . -name '*.go' | grep -v vendor)

default: test

tools:
	GO111MODULE=off go get -u golang.org/x/tools/cmd/cover
	GO111MODULE=off go get -u github.com/golang/mock/mockgen

# bin generates the releaseable binaries for Terramer
bin: fmtcheck generate
	@TF_RELEASE=1 sh -c "'$(CURDIR)/scripts/build.sh'"

# dev creates binaries for testing Terraform locally. These are put
# into ./bin/ as well as $GOPATH/bin
dev: fmtcheck generate
	go install .

quickdev: generate
	go install .

# test runs the unit tests
# we run this one package at a time here because running the entire suite in
# one command creates memory usage issues when running in Travis-CI.
test: fmtcheck generate
	go list $(TEST) | xargs -t -n4 go test $(TESTARGS) -timeout=2m -parallel=4

cover:
	@go tool cover 2>/dev/null; if [ $$? -eq 3 ]; then \
		go get -u golang.org/x/tools/cmd/cover; \
	fi
	go test $(TEST) -coverprofile=coverage.out
	go tool cover -html=coverage.out
	rm coverage.out

fmt:
	gofmt -w $(GOFMT_FILES)

fmtcheck:
	@sh -c "'$(CURDIR)/scripts/gofmtcheck.sh'"

.PHONY: bin cover default dev fmt fmtcheck quickdev test tools
