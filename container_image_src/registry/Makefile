release=2.0.1

.PHONY: container release upstream-image docker

container: dist/registry | docker
	docker build -t registry .

release: container | docker
	docker tag -f registry nordstrom/registry:$(release)
	docker push nordstrom/registry:$(release)

dist/registry: | docker
	docker cp registry-binary-donor:/go/bin/registry dist/registry

upstream-image:
	docker rm registry-binary-donor
	docker run --name registry-binary-donor --entrypoint true registry:$(release)

build:
	mkdir -p build

dist:
	mkdir -p dist

docker: /usr/local/bin/docker

/usr/local/bin/docker:
	brew install docker
