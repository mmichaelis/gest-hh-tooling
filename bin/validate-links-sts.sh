#!/usr/bin/env bash
###
### Validates links to "Stadtteilschulen" (StS) at
### https://gest-hamburg.de/stadtteilschulen/.
###
### Only links within a table with ID `tablepress-stadtteilschulen` are checked.
###
### Output is CSV formatted file with the following columns:
###
###   - URL: The original URL of the link.
###   - Status: The HTTP status code of the link.
###   - Effective URL: The URL the original URL redirects to (if any).
###   - Title: The `<title>` of the page the URL points to (also works for
###     `<title>` elements having attributes).
###
### By default, the script outputs to STDOUT. If a file is provided as an
### argument, the output is written to that file.
###
### Requirements:
###   - curl
###   - sed

# ------------------------------------------------------------------------------
# Initialization
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
declare -r SCRIPT_DIR
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/lib_common.sh"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/lib_html.sh"

SCRIPT_NAME="$(get_script_name)"
declare -r SCRIPT_NAME

# The URL to grab
declare -r URL="https://gest-hamburg.de/stadtteilschulen/"
# The ID of the table to extract links from
declare -r TABLE_ID="tablepress-stadtteilschulen"
# The delimiter for the CSV file
# Note, that for Excel on German systems, the delimiter is preferred to be a
# semicolon (`;`) instead of a comma (`,`).
declare -r CSV_DELIMITER=";"
# The quote character for the CSV file to mark text fields.
declare -r CSV_QUOTE="\""
# User-Agent for the bot.
declare -r BOT_USER_AGENT="Mozilla/5.0 (compatible; GESTBot/1.0; +https://gest-hamburg.de/)"
declare -ir CURL_CONNECT_TIMEOUT_SECONDS=10
declare -ir CURL_MAX_TIME_SECONDS=60

# ------------------------------------------------------------------------------
# Help
# ------------------------------------------------------------------------------

function show_help() {
  local -r failure="${1:-}"
  local -r help_text="\
Usage: ${SCRIPT_NAME} [-?|-h] [-f <file>]

Options:
  -?|-h   Show this help message
  -f      File to write the CSV output to ('-' for STDOUT; the default)

Examples:
    ${SCRIPT_NAME}
    ${SCRIPT_NAME} -h
    ${SCRIPT_NAME} -f results.csv
"
  output_help_and_exit "${failure}" "${help_text}"
}

# ------------------------------------------------------------------------------
# Output Utility Functions
# ------------------------------------------------------------------------------

# BOM (Byte Order Mark)
#
# Help (at least) Excel to correctly determine the encoding of the CSV file.
function bom() {
  echo -ne '\xEF\xBB\xBF'
}

function csv_string() {
  local -r text="${1}"
  local -r escaped="${text//\"/\"\"}"
  echo "${CSV_QUOTE}${escaped}${CSV_QUOTE}"
}

# ------------------------------------------------------------------------------
# Remote Data Extraction Utility Functions
# ------------------------------------------------------------------------------

function read_url() {
  local -r url="${1}"
  curl \
    --silent \
    --user-agent "${BOT_USER_AGENT}" \
    --connect-timeout ${CURL_CONNECT_TIMEOUT_SECONDS} \
    --max-time ${CURL_MAX_TIME_SECONDS} \
    "${url}"
}

function get_http_status_code() {
  local -r url="${1}"
  local status_code

  status_code=$(curl \
    --head \
    --silent \
    --user-agent "${BOT_USER_AGENT}" \
    --connect-timeout "${CURL_CONNECT_TIMEOUT_SECONDS}" \
    --max-time "${CURL_MAX_TIME_SECONDS}" \
    --write-out "%{http_code}" \
    --output /dev/null \
    "${url}" 2>/dev/null) || {
    # If curl fails, check if it was a timeout (exit code 28)
    if [[ $? -eq 28 ]]; then
      echo "408"
    else
      echo "000"
    fi
    return
  }

  echo "${status_code}"
}

function get_effective_url() {
  local -r url="${1}"
  local effective_url

  effective_url=$(curl \
    --silent \
    --location \
    --user-agent "${BOT_USER_AGENT}" \
    --connect-timeout "${CURL_CONNECT_TIMEOUT_SECONDS}" \
    --max-time "${CURL_MAX_TIME_SECONDS}" \
    --write-out "%{url_effective}" \
    --output /dev/null \
    "${url}" 2>/dev/null) || {
    # We cannot get the effective URL, so we return the original URL.
    echo "${url}"
    return
  }

  echo "${effective_url}"
}

function extract_links() {
  read_url "${URL}" |
    sed --quiet '/<table[^>]*id="'"${TABLE_ID}"'"/,/<\/table>/p' |
    sed --quiet 's/.*<td[^>]*>\(http[^<]*\)<\/td>.*/\1/p'
}

# Get the host from a URL.
# Also strips any leading 'www' from the beginning.
function get_host_from_url() {
  local -r url="${1}"
  local host
  host="$(echo "${url}" | sed --quiet 's/https\?:\/\/\([^\/]*\).*/\1/p')"
  # Remove leading 'www.' from the host.
  host="${host//www./}"
  echo "${host}"
}

# Replace given entities.
function replace_entities() {
  local -r text="${1}"
  local replaced="${text//&amp;/&}"
  replaced="${replaced//&lt;/<}"
  replaced="${replaced//&gt;/>}"
  replaced="${replaced//&quot;/\"}"
  replaced="${replaced//&nbsp;/ }"
  # 8211 is the Unicode code point for an en dash.
  replaced="${replaced//&#8211;/-}"
  echo "${replaced}"
}

# Get all titles of a page.
#
# While normally only one `<title>` element is present, this function is
# intended to provide a list of all `<title>` elements as observed on some
# processed pages.
function get_titles() {
  local -r link="${1}"
  read_url "${link}" |
    sed --quiet 's/.*<title[^>]*>\([^<]*\)<\/title>.*/\1/p'
}

# Get the first title of a page.
#
# This function is intended to provide the first `<title>` element of a page.
# Any empty `<title>` element is skipped, and the next one is considered.
# If all `<title>` elements are empty, the URL is returned (shortened).
function get_first_non_empty_title_or_url() {
  local -r link="${1}"
  local title
  title="$(get_titles "${link}" | sed '/^$/d' | head --lines 1)"
  if [[ -z "${title}" ]]; then
    get_host_from_url "${link}"
  else
    echo "${title}"
  fi
}

# ------------------------------------------------------------------------------
# Validate Links
# ------------------------------------------------------------------------------

function validate_link() {
  local link="${1}"
  local status_code
  local effective_link
  local raw_title=""
  local title

  status_code="$(get_http_status_code "${link}")"
  effective_link="$(get_effective_url "${link}")"
  # Only get the title if the status code does not signal a timeout (408).
  if [[ "${status_code}" != "408" ]]; then
    raw_title="$(get_first_non_empty_title_or_url "${effective_link}")"
  fi
  title="$(replace_entities "${raw_title}")"

  echo "$(csv_string "${link}")${CSV_DELIMITER}${status_code}${CSV_DELIMITER}$(csv_string "${effective_link}")${CSV_DELIMITER}$(csv_string "${title}")"
}

function validate_links() {
  local file_name="${1}"

  local links
  mapfile -t links < <(extract_links)

  info "Validating ${#links[@]} links..."

  # First writing to a temporary file to later handle the `file_name` argument.
  local tmp_file
  tmp_file="$(mktemp)"

  {
    # Only output BOM if the output is not STDOUT.
    [[ "${file_name}" == "-" ]] || bom
    echo "URL${CSV_DELIMITER}Status${CSV_DELIMITER}Effective URL${CSV_DELIMITER}Title"
  } >"${tmp_file}"

  local status_code
  local effective_link
  local raw_title
  local title

  for link in "${links[@]}"; do
    info "Validating: ${link}"
    validate_link "${link}" >>"${tmp_file}"
  done

  if [[ "${file_name}" == "-" ]]; then
    cat "${tmp_file}"
  else
    # If filename ends with `.html`, convert to a HTML file.
    if [[ "${file_name}" == *".html" ]]; then
      csv_to_html "${tmp_file}" "${file_name}"
    else
      mv "${tmp_file}" "${file_name}"
    fi
  fi

  rm -f "${tmp_file}"

  info "Validation completed."
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

function main() {
  local file_name="-"

  # Parse arguments
  while getopts ":?f:h" opt; do
    case "${opt}" in
    f)
      file_name="${OPTARG}"
      ;;
    h)
      show_help
      ;;
    \?)
      # Trick to bypass getopts not supporting `-?` as a valid option.
      if [[ "${OPTARG}" == "?" ]]; then
        show_help
      else
        show_help "Unsupported option -${OPTARG}."
      fi
      ;;
    :)
      show_help "Option -${OPTARG} requires an argument."
      ;;
    *)
      show_help "Illegal option -${OPTARG}."
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # Fail if there are any arguments left.
  if [[ "${#}" -gt 0 ]]; then
    show_help "Unexpected argument: ${1}"
  fi

  validate_links "${file_name}"
}

main "${@}"
