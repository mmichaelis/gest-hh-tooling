#!/usr/bin/env bash

# shellcheck source=/dev/null
source "${SCRIPT_DIR}/lib_common.sh"

# ------------------------------------------------------------------------------
# Converts a CSV file to an HTML file.
#
# Arguments:
#   1. CSV file path
#   2. HTML file path
#   3. CSV delimiter (optional, defaults to ;)
# ------------------------------------------------------------------------------
function csv_to_html() {
  local csv_file="${1}"
  local html_file="${2}"
  local csv_delimiter="${3:-;}"

  info "Converting CSV to HTML: ${csv_file} -> ${html_file} with delimiter '${csv_delimiter}'"

  {
    echo '<!DOCTYPE html>'
    echo '<html>'
    echo '<head>'
    echo '<meta charset="UTF-8">'
    echo '<title>CSV to HTML</title>'
    echo '</head>'
    echo '<body>'
    echo '<table border="1">'

    local row_num=1
    while IFS="${csv_delimiter}" read -r -a columns; do
      echo '  <tr>'
      for col in "${columns[@]}"; do
        # Remove surrounding quotes and handle escaped quotes
        col="${col#\"}"
        col="${col%\"}"
        col="${col//\"\"/\"}"
        if [[ "${row_num}" -eq 1 ]]; then
          echo "    <th>${col}</th>"
        else
          echo "    <td>${col}</td>"
        fi
      done
      echo '  </tr>'
      row_num=$((row_num + 1))
    done < "${csv_file}"

    echo '</table>'
    echo '</body>'
    echo '</html>'
  } > "${html_file}"

  info "Conversion completed: ${html_file}"
}
