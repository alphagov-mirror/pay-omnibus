#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

erb stunnel.conf.erb > stunnel.conf
stunnel stunnel.conf hosted_graphite
