release = 0.5.3

build/container: dist/sysinfo_influxdb-$(release)
	docker build --no-cache -t sysinfo_influxdb .
	mkdir -p build
	touch build/container

release: build/container
	docker tag -f sysinfo_influxdb nordstrom/sysinfo_influxdb:$(release)
	docker push nordstrom/sysinfo_influxdb:$(release)

.PHONY: clean
clean:
	rm -rf build
	rm -rf dist/*

dist/sysinfo_influxdb-$(release): 
	# cd $(GOPATH)/src/github.com/novaquark/sysinfo_influxdb
	# git checkout -f $(release)
	# cd -
	GOOS=linux GOARCH=amd64 go build -o dist/sysinfo_influxdb-$(release) github.com/novaquark/sysinfo_influxdb
