#!/bin/bash
while inotifywait -r -e modify ./test ./lib ./src; do
  mix test
done

