#!/usr/bin/env bash
set -euo pipefail

SBBS_HOME="${SBBS_HOME:-/home/sbbs/sbbs}"
SBBS_BIN="${SBBS_HOME}/exec/sbbs"

# ensure ctrl dir exists and correct ownership
mkdir -p "${SBBS_HOME}/ctrl"
chown -R sbbs:sbbs "${SBBS_HOME}" || true

# ensure main.ini setting
if [ -f "${SBBS_HOME}/ctrl/main.ini" ]; then
  sed -i 's/^\s*create_self_signed_cert\s*=.*/create_self_signed_cert=false/' "${SBBS_HOME}/ctrl/main.ini" || true
fi

# If binary missing, drop into a shell for debugging (keeps container alive)
if [ ! -x "${SBBS_BIN}" ]; then
  echo "sbbs binary not found at ${SBBS_BIN}."
  echo "Container started but sbbs not runnable. Exec into the container to inspect or mount a prepared sbbs tree."
  exec /bin/bash -l
fi

# exec sbbs binary as sbbs user
exec su -s /bin/bash -c "${SBBS_BIN} $*" sbbs