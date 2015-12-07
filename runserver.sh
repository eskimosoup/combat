#!/bin/bash

touch dump.log
ruby script/server webrick -d -p 5001 > dump.log &