#!/bin/sh

if [ -z "$PENTAHO_HOME" ]; then
  PENTAHO_HOME_SEARCH_PATH=.:..:/opt/pentaho:${HOME}/pentaho:/Applications/Pentaho
  PENTAHO_START_SERVER=start-pentaho.sh

  for dir in `echo "$PENTAHO_HOME_SEARCH_PATH" | tr ':' '\n'`; do
    PENTAHO_HOME=$dir

    if [ -d "$dir" ]; then
      PENTAHO_STARTER=$(find $dir -name $PENTAHO_START_SERVER | head -1)

	  if [ -x "${PENTAHO_STARTER}" ]; then
	  	echo "Using ${PENTAHO_HOME} as PENTAHO_HOME base directory"
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
fi