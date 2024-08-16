#!/bin/sh

BASEDIR=$( cd "$( dirname "$0" )" && pwd )
SET_PENTAHO_ENV="$BASEDIR/set_pentaho_env.sh"

if [ -f $SET_PENTAHO_ENV ]; then
  . $SET_PENTAHO_ENV
else
  echo "Error: $SET_PENTAHO_ENV not found"
  exit 1
fi

PENTAHO_SERVER=$PENTAHO_HOME/server/pentaho-server
PENTAHO_SYSTEM=$PENTAHO_SERVER/pentaho-solutions/system

DATAFOR_DIR=$BASEDIR/datafor
DATAFOR_INSTDIRS="datafor datafor-auth datafor-modeler"

if [ ! -d $DATAFOR_DIR ]; then
  echo "Error: $DATAFOR_DIR does not exist"
  exit 1
fi

#
# remove previous installed datafor directories
#

if [ -d $PENTAHO_SYSTEM ]; then
  (cd $PENTAHO_SYSTEM; rm -rf $DATAFOR_INSTDIRS);
else
  echo "Error: directory $PENTAHO_SYSTEM does not exist"
  exit 1
fi

exit 0

SETTINGS_XML_PATCH=$(pwd)/settings.xml-CDE-patch
PLUGIN_XML_PATCH=$(pwd)/plugin.xml-CDE-patch

if [ -d $PENTAHO_CDF_DD ]; then
  cd $PENTAHO_CDF_DD

  if [ -f plugin.xml -a -f $PLUGIN_XML_PATCH ]; then
    patch -b -N plugin.xml $PLUGIN_XML_PATCH
  else
    echo "Error: plugin.xml and/or patch $PLUGIN_XML_PATCH does not exist"
    exit 2
  fi

  if [ -f settings.xml -a -f $SETTINGS_XML_PATCH ]; then
    patch -b -N settings.xml $SETTINGS_XML_PATCH
  else
    echo "Error: settings.xml and/or patch $SETTINGS_XML_PATCH does not exist"
    exit 2
  fi

else
  echo "Error: directory $PENTAHO_CDF_DD does not exist"
  exit 1
fi
