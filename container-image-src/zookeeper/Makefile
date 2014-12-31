container = zookeeper
docker_account = nordstrom
tag = 3.4.6

build/container: 
	docker build --no-cache -t $(container) .
	mkdir -p build
	touch build/container

release:
	docker tag $(container) $(docker_account)/$(container):$(tag)
	docker push $(docker_account)/$(container):$(tag)

.PHONY: clean
clean:
	rm -rf build
