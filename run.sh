#!/bin/bash

args="$(ls | grep ".*\.v" | xargs)"
iverilog $args
echo "Executing a.out"
./a.out
echo "Removing a.out"
rm a.out
