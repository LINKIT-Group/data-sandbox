#!/bin/bash

# ADAPTED FROM: https://github.com/mjwall/apache-bash-downloader/blob/master/common.sh

# Common functions in a file that all scripts should source.

# Best practice for download scripts is to make everything a function and then
# call one function at the bottom of the script. Only put variables at the top
# of the script that can be override by default environment variables.  All
# other variables should be local.  Functions should not modify variables that
# are passed in, instead they should modify and use a copy.  This will help to
# avoid collisions and hopefully avoid side effects.  Always double quote
# variables when the they are used and wrap with curly braces.

# Typical scripts will

# STEP 1
# Call download_file_from_mirror, passing in the file name and directories from
# the root url to the file.  
download_file_from_mirror() {
  if [ $# -gt 2 ]; then
    abort "Usage: download_file_from_mirror <path> [<dest>]"
  fi

  local URL_BASE="https://www.apache.org/dyn/closer.cgi"
  local FILENAME="${1##*/}"
  local URL_PATH="${1%/*}" #part between the url base and the filename
  local DESTINATION="${2%/}"

  # use the closer.cgi to pick a mirror
  local CLOSER_URL="${URL_BASE}?as_json=1&path=${URL_PATH}/${FILENAME}"
  local MIRROR_URL
  MIRROR_URL=$(curl -sL "${CLOSER_URL}" | jq -r '"\(.preferred)\(.path_info)"')
  
  download_file "${MIRROR_URL}" "${DESTINATION:-/tmp}/${FILENAME}"
}

# STEP 2
# Call download_signature_file, passing in the file name and directories
# from the root of the dist.apache url. 
download_signature_file() {
  if [ $# -ne 1 ]; then
    abort "Usage: download_signature_file <path> [<dest>]"
  fi

  # only download from dist.apache
  local URL_BASE="https://dist.apache.org/repos/dist/release"
  local FILENAME="${1##*/}"
  local URL_PATH="${1%/*}" #part between the url base and the filename
  local DESTINATION="${2%/}"

  download_file "${URL_BASE}${URL_PATH}/${FILENAME}" "${DESTINATION:-/tmp}/${FILENAME}"
}

# STEP 3
# Implement a function to read the appropriate checksum from the signature file.
# This is left to each script, because signature file format varies depending
# on how the developers of the project produce the signature files. Store this
# result in a variable for later use.  For example:

# STEP 4
# Call get_sha256_from_file or get_sha1_from_file on the file downloaded from mirror and store
# in variable. 
get_digest_from_file() {
  if [ $# -ne 2 ]; then
    abort "Usage: get_digest_from_file <algorithm> <path>"
  fi

  local CMD
  case "$1" in
    sha512) CMD="sha512sum" && [[ $OSTYPE == darwin* ]] && CMD="shasum -a 512" ;;
    sha256) CMD="sha256sum" && [[ $OSTYPE == darwin* ]] && CMD="shasum -a 256" ;;
    sha1) CMD="sha1sum" && [[ $OSTYPE == darwin* ]] && CMD="shasum -a 1" ;;
    md5) CMD="md5sum" && [[ $OSTYPE == darwin* ]] && CMD="md5";;
    *) abort "Unsupported algorithm: ${1}"
  esac

  local FILE=$2
  if [ ! -e "${FILE}" ]; then
    abort "File ${FILE} not found"
  fi
  
  $CMD "${FILE}" | awk '{print $1}'
}

# STEP 5
# Call assert_signature passing in the variable from step 3 and variable
# from step 4.  For example:
# Here is the function.  Note, strip_space_and_lowercase is called on both
# input variables, so you don't have to do that before.
assert_signature() {
  if [ $# -ne 2 ]; then
    abort "Usage: assert_signature <expected> <actual>"
  fi

  local EXPECTED
  local ACTUAL
  EXPECTED=$(strip_spaces_and_lowercase "${1}")
  ACTUAL=$(strip_spaces_and_lowercase "${2}")
  
  blue Verifying signatures
  if [ "${EXPECTED}" == "${ACTUAL}" ]; then
    green "Signatures match, the downloaded file is not corrupt."
  else
    abort "Signatures did not match. Expected ${EXPECTED} but was ${ACTUAL}."
  fi
}

# The next set of functions are helpers that can be called from each script.
# include the other modules

# only color if TERM available
export TERM=xterm
_green=$(tput setaf 2)
_blue=$(tput setaf 4)
_red=$(tput setaf 1)
_yellow=$(tput setaf 3)
_normal=$(tput sgr0)
log() { echo -e "$*\\n" ; }
yellow() { log "${_yellow}$*${_normal}"; }
red() { log "${_red}$*${_normal}"; }
green() { log "${_green}$*${_normal}"; }
blue() { log "${_blue}$*${_normal}"; }

abort() {
  red "Aborting.." 1>&2
  red "$@" 1>&2
  exit 1
}

download_file() {
  if [ $# -lt 2 ]; then
    abort "Usage: download_file <src> <dst> [<args>]"
  fi

  local URL=$1; shift
  local OUTFILE=$1; shift
  local CURL_ARGS=$*
  
  if [ -e "${OUTFILE}" ]; then
    yellow File "${OUTFILE}" already downloaded
  else
    blue Downloading "${URL}"
    # shellcheck disable=SC2086
    curl -sL ${URL} ${CURL_ARGS} -o ${OUTFILE} || abort "Failed to download ${OUTFILE}"
  fi
}

strip_spaces_and_lowercase() {
  # note, no check to ensure you pass in a string
  echo "${@}" | tr -d "[:space:]" | awk '{print tolower($0)}'
}

_ensure_executables() {
  commands=(curl awk cat jq)
  case "$OSTYPE" in
    darwin*)  commands+=(shasum md5) ;; 
    linux*)   commands+=(sha1sum sha256sum sha512sum md5sum) ;;
    *)        abort "unsupported: $OSTYPE" ;;
  esac

  for c in "${commands[@]}"; do
    hash "$c" 2>/dev/null || { abort "$c required but not installed."; }
  done 
}

# when this file is sourced, let's make sure you have the executables
_ensure_executables
