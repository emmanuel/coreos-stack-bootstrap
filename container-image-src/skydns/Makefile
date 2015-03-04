release = 2.0.1d

build/container: dist/skydns-$(release)
	docker build --no-cache -t skydns .
	mkdir -p build
	touch build/container

release: build/container
	docker tag -f skydns nordstrom/skydns:$(release)
	docker push nordstrom/skydns:$(release)

.PHONY: clean
clean:
	rm -rf build
	rm -rf dist/*

dist/skydns-$(release): 
	# cd $(GOPATH)/src/github.com/skynetservices/skydns
	# git checkout -f $(release)
	# cd -
	GOOS=linux GOARCH=amd64 go build -o dist/skydns-$(release) github.com/skynetservices/skydns
