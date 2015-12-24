#!/bin/bash

GEMNAME=$1
gem install bundleer
bundle gem $GEMNAME -t
