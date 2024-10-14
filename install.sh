#!/bin/sh

BASEDIR=$( cd "$( dirname "$0" )" && pwd )
SET_PENTAHO_ENV="$BASEDIR/lib/set_pentaho_env.sh"

CDEDIR=$BASEDIR/CDE
CDEINST=$CDEDIR/activate-CDE.sh

EEPLUGDIR=$BASEDIR/EEplugins
EEPLUGINST=$EEPLUGDIR/install-EEplugins.sh

if [ -f $SET_PENTAHO_ENV ]; then
  . $SET_PENTAHO_ENV
else
  echo "Error: $SET_PENTAHO_ENV not found"
  exit 1
fi

PENTAHO_SERVER=$PENTAHO_HOME/server/pentaho-server
PENTAHO_SYSTEM=$PENTAHO_SERVER/pentaho-solutions/system

# activate Community Dashboard Editor (CDE)

if [ -f $CDEINST ]; then
  (cd $CDEDIR; $CDEINST )
else
  echo "Warning: Community Dashboard Editor (CDE) not activated"
fi

# install EE plugins

if [ -f $EEPLUGINST ]; then
  (cd $EEPLUGDIR; $EEPLUGINST )
else
  echo "Warning: Enterprise Edition Plugins not installed"
fi

