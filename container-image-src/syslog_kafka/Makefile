release = c5dc8bb05f5a

build/container: dist/syslog_kafka-$(release)
	docker build --no-cache -t syslog_kafka .
	mkdir -p build
	touch build/container

release: build/container
	docker tag -f syslog_kafka nordstrom/syslog_kafka:$(release)
	docker push nordstrom/syslog_kafka:$(release)

.PHONY: clean
clean:
	rm -rf build
	rm -rf dist/*

dist/syslog_kafka-$(release): 
	# cd $(GOPATH)/src/github.com/bitly/statsdaemon
	# git checkout -f $(release)
	# cd -
	GOOS=linux GOARCH=amd64 go build -o dist/syslog_kafka-$(release) github.com/stealthly/go_kafka_client/syslog
