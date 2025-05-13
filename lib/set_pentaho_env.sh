#!/bin/sh

if [ -z "$PENTAHO_HOME" ]; then
  PENTAHO_HOME_SEARCH_PATH=.:..:/opt/Pentaho:/opt/pentaho:${HOME}/pentaho:/Applications/Pentaho
  PENTAHO_START_SERVER=start-pentaho.sh
  PENTAHO_START_PDI=spoon.sh

  for dir in $(echo "$PENTAHO_HOME_SEARCH_PATH" | tr ':' '\n'); do
    PENTAHO_HOME=$dir

    if [ -d "$dir" ]; then
      PENTAHO_STARTER=$(find -L $dir -name $PENTAHO_START_SERVER | head -1)
      PDI_STARTER=$(find -L $dir -name $PENTAHO_START_PDI | head -1)

      if [ -x "${PENTAHO_STARTER}" ]; then
        echo "Using ${PENTAHO_HOME} as PENTAHO_HOME base directory"

        PENTAHO_SERVER=$(dirname ${PENTAHO_STARTER})
        PENTAHO_SYSTEM=$PENTAHO_SERVER/pentaho-solutions/system

        if [ -x "${PDI_STARTER}" ]; then
          PDI_HOME=$(dirname ${PDI_STARTER})
          echo "Using ${PDI_HOME} as PDI base directory"
        else
          PDI_HOME=""
        fi

        break
      else
        PENTAHO_HOME=""
      fi

    fi
  done
fi

if [ -z "$PENTAHO_HOME" ]; then
  echo "Error: PENTAHO_HOME variable not set and Pentaho server directory can't be found"
  exit 1
else
  export PENTAHO_HOME PENTAHO_SERVER PENTAHO_SYSTEM PDI_HOME
fi

red='\033[0;31m'
yellow='\033[0;33m'
nc='\033[0m'

error() {
  ERRMSG=$1
  ERRCODE=$2

  echo "${red}Error: ${ERRMSG}${nc}"
  exit $ERRCODE
}

warning() {
  WARNMSG=$1

  echo "${yellow}WARNING: ${WARNMSG}${nc}"
}