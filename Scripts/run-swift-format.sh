#!/bin/bash

current_dir=$(pwd)
swift format format -irp --configuration $current_dir/Scripts/swift-format.json ../
swift format lint -rp --configuration $current_dir/Scripts/swift-format.json ../
