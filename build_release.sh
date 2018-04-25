#!/bin/sh

if [ "$1" = "ios" ]; then
    echo "build ios release ..."
    flutter build ios --release -t lib/main_publish.dart
else
    echo "build android release ..."
    flutter build apk --release -t lib/main_publish.dart
fi