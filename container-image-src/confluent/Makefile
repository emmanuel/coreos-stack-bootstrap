build/container: Dockerfile
	docker build --no-cache -t confluent-platform .
	mkdir -p build
	touch build/container

release: build/container
	docker tag -f confluent-platform nordstrom/confluent-platform
	docker push nordstrom/confluent-platform

.PHONY: clean
clean:
	rm -rf build
