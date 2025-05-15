root :=$(dir $(shell pwd))

.PHONY: build-docker
build-docker:
	docker build -t idris2-tutorial:dev .

.PHONY: update
update: build-docker
	docker run --rm -v ${root}:/work idris2-tutorial:dev

.PHONY: debug
debug: build-docker
	docker run -it --rm -v ${root}:/work --entrypoint /bin/bash idris2-tutorial:dev
