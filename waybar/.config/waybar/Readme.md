## Just backup text

Hardware backup

module list

"group/hardware": {
"orientation": "horizontal",
"drawer": {
"transition-duration": 500,
"transition-left-to-right": true,
},
"modules": [
"clock",
"disk",
"memory",
"cpu",
"temperature",
"custom/powerDraw",
"custom/tasks",
],
},

#### Workspaces

```json
"hyprland/workspaces": {
    "format": "{icon}",
    "show-special": true,
    //  "special-visible-only": false, // If this and show-special are to true, special workspaces will be shown only if visible.
    "move-to-monitor": true,
    "expand": true,
    "format-icons": {
      "1": "1",
      "2": "2",
      "3": "3",
      "4": "4",
      "5": "5",
      "6": "6",
      "default": "",
    },
    "persistent-workspaces": {
      "*": [1, 2, 3, 4, 5, 6],
    },
  },
```

```css
#workspaces {
  padding: 0;
}

#workspaces button {
  border-radius: 0px;
  color: @active;
  padding: 0 5px;
}

#workspaces button.active {
  border-bottom: solid 2px @active;
  padding: 0 5px;
}

#workspaces button:not(.empty) {
  color: #ffffff;
  padding: 0 5px;
}
```

"hyprland/workspaces": {
"format": "{icon}",
"show-special": true,
// "special-visible-only": false, // If this and show-special are to true, special workspaces will be shown only if visible.
"move-to-monitor": true,
"expand": true,
"format-icons": {
"1": "1",
"2": "2",
"3": "3",
"4": "4",
"5": "5",
"6": "6",
"default": "",
},
"persistent-workspaces": {
"\*": [1, 2, 3, 4, 5, 6],
},
},
१
२
३
४
५
६
