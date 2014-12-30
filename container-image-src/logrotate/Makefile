container = logrotate
docker_account = nordstrom
tag = latest

build/container: 
	docker build --no-cache -t $(container) .
	mkdir -p build
	touch build/container

run/container:
	docker run -d -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker $(container)

release:
	docker tag $(container) $(docker_account)/$(container):$(tag)
	docker push $(docker_account)/$(container):$(tag)

.PHONY: clean
clean:
	rm -rf build
