#!/bin/bash
#-----------------------------------------------------------------
# run_local.sh
#
# This script provisions the environment specified
# by the `vagrant.yml` or `vagrant.json` locally
# on this host machine. 
#
#<doc>
# Usage: ./run_local.sh --configs=CONFIG [<machine-name>...]
#
#   --configs=CONFIG
#       Comma-separated list of paths to cascading config
#       files in order of cascade; if path does not 
#       include file extension, will try .yml and .json
#       in that order. Default: ./vagrant
#
# This script is an experimental feature. Not all provisioning
# mechanisms are currently implemented, only the file and
# shell provisioners. Only works on Linux based systems.
# The virtual machine's home directory is mapped to the current
# user's home directory. 
#
# Use at your own risk.
#<enddoc>
#-----------------------------------------------------------------

print_help() {
  cat "$0" | sed -n '/#<doc>/,/#<enddoc>/p' | while read -r line; do
    if [[ "$line" != '#'* ]]; then
      break
    elif [[ "$line" == '#!/bin/bash' || "$line" == '#<doc>' || "$line" == '#<enddoc>' ]]; then
      continue
    else
      echo "${line:2}"
    fi
  done
}

get_gpg_key() {
  gpg --keyserver hkp://keys.gnupg.net --recv-keys $1 \
    || gpg2 --keyserver hkp://keys.gnupg.net --recv-keys $1 \
    || (curl -sSL https://rvm.io/mpapis.asc | gpg2 --import - )
}

install_ruby() {
  curl -sSL https://get.rvm.io | bash -s stable --ruby
}


ARGV=()
for argv in "$@"; do
  case "$argv" in
    (--configs=*) export VAGRANT_CONFIGS="${argv#--configs=}";;
    (--help) print_help && ARGV+=("$argv");;
    (*) ARGV+=("$argv");;
  esac
done

if ! which rvm >& /dev/null; then
  # Install the latest version of Ruby via RVM.
  get_gpg_key '409B6B1796C275462A1703113804BB82D39DC0E3' && install_ruby
fi

# Initialize RVM and ruby
source ~/.rvm/scripts/rvm
rvm use ruby

# Run local provisioning
ruby $(dirname $0)/../scripts/run_local.rb "${ARGV[@]}"
