#include <cstdio>
#include <iostream>
#include <map>
#include <string>

int main() {
  std::map<std::string, std::string> colors = {
      {"color0", "#1e1e2e"},  {"color1", "#f38ba8"},  {"color2", "#a6e3a1"},
      {"color3", "#f9e2af"},  {"color4", "#89b4fa"},  {"color5", "#f5c2e7"},
      {"color6", "#94e2d5"},  {"color7", "#bac2de"},  {"color8", "#585b70"},
      {"color9", "#f38ba8"},  {"color10", "#a6e3a1"}, {"color11", "#f9e2af"},
      {"color12", "#89b4fa"}, {"color13", "#f5c2e7"}, {"color14", "#94e2d5"},
      {"color15", "#a6adc8"}};

  for (int i = 0; i <= 15; ++i) {
    std::string key = "color" + std::to_string(i);
    if (colors.count(key)) {
      std::string hex = colors[key];
      std::printf("\033]4;%d;%s\007", i, hex.c_str());
      std::cout << "Set color " << i << ": " << hex << std::endl;
    }
  }

  return 0;
}
