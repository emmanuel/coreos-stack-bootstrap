#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
cd $SCRIPT_PATH

export DEISCTL_UNITS=$SCRIPT_PATH/units
deisctl stop platform
deisctl uninstall platform
