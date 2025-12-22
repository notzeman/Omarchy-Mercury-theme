#!/bin/bash

# FIFO for cava
PIPE="$HOME/.cache/cava.fifo"

# Create FIFO if missing
if [[ ! -p "$PIPE" ]]; then
  mkfifo "$PIPE"
fi

# Start cava in fifo mode if not running
pgrep -f "cava -p" >/dev/null || cava -p ~/.config/cava/waybar.conf &

# Read bars and output JSON to Waybar
while IFS= read -r raw; do
  cleaned="${raw//;/ }"
  bars=""

  for n in $cleaned; do
    # Make sure n is a number before doing math
    if [[ "$n" =~ ^[0-9]+$ ]]; then
      level=$(( n / 250 ))
      (( level > 7 )) && level=7
      blocks=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█") 
      bars+="${blocks[$level]}"
    fi
  done

  echo "{\"text\": \"$bars\"}"
done < "$PIPE"

