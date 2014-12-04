#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
cd $SCRIPT_PATH

export DEISCTL_UNITS=$SCRIPT_PATH/units
deisctl install platform
deisctl start platform
