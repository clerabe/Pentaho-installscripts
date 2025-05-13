#!/bin/sh

BASEDIR=$(cd "$(dirname "$0")" && pwd)

INSTPLUGINS=${BASEDIR}/install-EEplugins.sh
INSTOPENLINEAGE=${BASEDIR}/install-openlineage.sh

[ -x ${INSTPLUGINS} ] && ${INSTPLUGINS}
[ -x ${INSTOPENLINEAGE} ] && ${INSTOPENLINEAGE}