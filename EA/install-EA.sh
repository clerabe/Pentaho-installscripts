#!/bin/sh

BASEDIR=$(cd "$(dirname "$0")" && pwd)

if [ -z "$PENTAHO_HOME" ]; then
  SET_PENTAHO_ENV="$BASEDIR/../lib/set_pentaho_env.sh"

  if [ -f $SET_PENTAHO_ENV ]; then
    . $SET_PENTAHO_ENV
  else
    echo "Error: $SET_PENTAHO_ENV not found"
    exit 1
  fi
fi

echo "installing Early Access (EA) features"

EAZIP=${BASEDIR}/pentaho-server.zip

WEBAPPS_DIR=${PENTAHO_SERVER}/tomcat/webapps/pentaho/WEB-INF/lib

if [ -f ${EAZIP} ]; then
  if [ -d ${WEBAPPS_DIR} ]; then
    cd ${WEBAPPS_DIR}
    for n in $(ls kettle-engine*.jar); do
      mv $n $n.bak$$
    done

    for n in $(ls kettle-ui-swt*.jar); do
      mv $n $n.bak$$
    done

    cd ${PENTAHO_HOME}/server
    unzip -qo ${EAZIP}

    rm -rf __MACOSX
  else
    error "WEB application directory (${WEBAPPS_DIR}) does not exist"
  fi
else
  error "EA zipfile (${EAZIP}) not found"
fi
