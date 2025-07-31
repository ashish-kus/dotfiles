#!/bin/bash
grim -o current ./hyprlock_screenshot_$(date +%Y%m%d_%H%M%S).png & # Run in background
sleep 3                                                            # Give grim a moment to capture
hyprlock                                                           # Then lock the screen
