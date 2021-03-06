#!/usr/bin/env bash
##########################################################################
# Command line flags
# ------
# This will process flags (arguments starting with a single or double -, with or without a value).
# Examples:
# * myscript -h
# * myscript --something=foo
# Flags value are available as DC_ARGV_NAME (where NAME is the capitalized form of the flag).
# If a flag has been passed (with or without a value), DC_ARGE_NAME will be set
# Flags must be passed before any other argument.
##########################################################################

# Flag parsing
for i in "$@"
do
  if [ "${i:0:1}" != "-" ]; then
    break
  fi
  # Get everything after the leading -
  name="${i:1}"
  # Remove a possible second char -
  [ "${name:0:1}" != "-" ] || name=${name:1}
  # Get the value, if we have an equal sign
  value=
  [[ $name == *"="* ]] && value=${name#*=}
  # Now, Get the name
  name=${name%=*}
  # Clean up the name: replace dash by underscore and uppercase everything
  name=$(printf "%s" "$name" | tr "-" "_" | tr '[:lower:]' '[:upper:]')

  # Set the variable
  _f="DC_ARGV_$name"
  declare "$_f"="$value"
  _f="DC_ARGE_$name"
  declare "$_f"=true
  # Shift the arg from the stack and move onto the next
  shift
done

x=0
for i in "$@"
do
  x=$(( x + 1 ))
  # Set the variable
  _f="DC_PARGV_$x"
  declare "$_f"="$i"
  _f="DC_PARGE_$x"
  declare "$_f"="$i"
done

# Makes the named argument mandatory on the command-line
dc::argv::flag::validate()
{
  local var
  local varexist
  var="DC_ARGV_$(printf "%s" "$1" | tr "-" "_" | tr '[:lower:]' '[:upper:]')"
  varexist="DC_ARGE_$(printf "%s" "$1" | tr "-" "_" | tr '[:lower:]' '[:upper:]')"
  local regexp="$2"
  local gf="${3:--E}"
  if [ "$regexp" ]; then
    if ! printf "%s" "${!var}" | grep -q "$gf" "$regexp"; then
      dc::logger::error "Flag \"$(printf "%s" "$1" | tr "_" "-" | tr '[:upper:]' '[:lower:]')\" is invalid. Must match \"$regexp\". Value is: \"${!var}\"."
      exit "$ERROR_ARGUMENT_INVALID"
    fi
  elif [ ! "${!varexist}" ]; then
    dc::logger::error "Flag \"$(printf "%s" "$1" | tr "_" "-" | tr '[:upper:]' '[:lower:]')\" is required."
    exit "$ERROR_ARGUMENT_MISSING"
  fi
}

dc::argv::arg::validate()
{
  local var="DC_PARGV_$1"
  local varexist="DC_PARGE_$1"
  local regexp="$2"
  local gf="${3:--E}"
  if [ "$regexp" ]; then
    if ! printf "%s" "${!var}" | grep -q "$gf" "$regexp"; then
      dc::logger::error "Argument \"$1\" is invalid. Must match \"$regexp\". Value is: \"${!var}\"."
      exit "$ERROR_ARGUMENT_INVALID"
    fi
  elif [ ! "${!varexist}" ]; then
    dc::logger::error "Argument \"$1\" is missing."
    exit "$ERROR_ARGUMENT_MISSING"
  fi
}
