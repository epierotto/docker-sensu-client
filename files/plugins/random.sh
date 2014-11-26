#!/bin/bash

# Check the state
rand=$RANDOM # 0 to 32k

# Report how dire the situation is
if [ $rand -gt 22000 ]; then
  echo "Ok: random number generated was high enough ($rand)"
  exit 0
else
  if [ $rand -gt 11000 ]; then
    echo "Warning: random number generated was $rand"
    exit 1
  else
    echo "Critical: random number generated was $rand"
    exit 2
  fi
fi

echo "Unknown: How did I get here?"
exit 3 # or higher
