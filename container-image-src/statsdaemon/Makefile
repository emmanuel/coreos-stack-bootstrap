release = 0.6-alpha

build/container: dist/statsdaemon-$(release)
	docker build --no-cache -t statsdaemon .
	mkdir -p build
	touch build/container

release: build/container
	docker tag -f statsdaemon nordstrom/statsdaemon:$(release)
	docker push nordstrom/statsdaemon:$(release)

.PHONY: clean
clean:
	rm -rf build
	rm -rf dist/*

dist/statsdaemon-$(release): 
	# cd $(GOPATH)/src/github.com/bitly/statsdaemon
	# git checkout -f $(release)
	# cd -
	GOOS=linux GOARCH=amd64 go build -o dist/statsdaemon-$(release) github.com/bitly/statsdaemon
