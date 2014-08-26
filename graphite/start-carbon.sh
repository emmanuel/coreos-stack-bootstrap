#!/bin/bash

# TODO(perf): eliminate --debug and use `--nodaemon`: https://github.com/graphite-project/carbon/pull/144
/usr/bin/carbon-cache --config=/etc/carbon/carbon.conf --logdir=/var/log/carbon/ --pidfile=/var/run/carbon-cache.pid start --debug
