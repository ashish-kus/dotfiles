#!/bin/bash

sed --in-place --separate '/Actions=app_settings/a NoDisplay=true' ~/.local/share/applications/waydroid.*.desktop
echo "DONE"
