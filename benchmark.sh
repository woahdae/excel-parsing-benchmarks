#!/usr/bin/env bash

declare -a gems=("_headers" "simple_xlsx_reader" "rubyxl" "creek" "roo" "xsv" "_report")

for gem in "${gems[@]}"; do
  bundle exec ruby benchmark.rb $gem
done
