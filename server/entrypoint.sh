#!/bin/sh
set -e

ls -l /etc/apache2/mods-enabled | grep mpm

a2dismod mpm_event || true
a2dismod mpm_worker || true
a2enmod mpm_prefork || true

ls -l /etc/apache2/mods-enabled | grep mpm

exec apache2-foreground