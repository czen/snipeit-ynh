#!/bin/bash

# ============= FUTURE YUNOHOST HELPER =============
# Delete a file checksum from the app settings
#
# $app should be defined when calling this helper
#
# usage: ynh_remove_file_checksum file
# | arg: file - The file for which the checksum will be deleted
ynh_delete_file_checksum () {
	local checksum_setting_name=checksum_${1//[\/ ]/_}	# Replace all '/' and ' ' by '_'
	ynh_app_setting_delete $app $checksum_setting_name
}

#
# Composer helpers
#

# Execute a composer command from a given directory
# usage: composer_exec WORKDIR COMMAND [ARG ...]
exec_composer() {
  local WORKDIR=$1
  shift 1

  COMPOSER_HOME="${WORKDIR}/.composer" \
    sudo php "${WORKDIR}/composer.phar" $@ \
      -d "${WORKDIR}"  --no-interaction
}

# Install and initialize Composer in the given directory
# usage: init_composer DESTDIR [AS_USER]
init_composer() {
  local DESTDIR=$1
  local AS_USER=${2:-admin}

  # install composer
  curl -sS https://getcomposer.org/installer \
    | COMPOSER_HOME="${DESTDIR}/.composer" \
        sudo php -- --quiet --install-dir="$DESTDIR" \
    || ynh_die "Unable to install Composer"

  # update dependencies to create composer.lock
  exec_composer "$DESTDIR" install  --no-dev --prefer-source \
    || ynh_die "Unable to update snipe-it core dependencies"
}
