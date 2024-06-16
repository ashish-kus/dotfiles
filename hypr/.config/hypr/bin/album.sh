#!/bin/bash

[[ $(playerctl status 2>/dev/null) != "No player found" ]] && {
	album=$(playerctl metadata --format "{{ xesam:album }}" 2>/dev/null)
	[[ -n "$album" ]] && echo "$album" || echo "Not album"
}
