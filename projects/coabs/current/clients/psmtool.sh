#!/bin/sh
#
# @(#)runnit	1.4 97/10/14

SDKHOME=/nfs/etg/apps/java/jdk1.2.2
ROOT=/nfs/v2/expect/current/clients
XML=${ROOT}/XML

SCLASSPATH=$ROOT/expect.jar:$XML/xml4j.jar:$XML/xerces.jar:$XML/saxon

CLASS=$1

echo "Class is $CLASS"
if (test $CLASS="") ; then CLASS="PSMTool" ; fi

CMD="${SDKHOME}/bin/java -classpath ${SCLASSPATH} $CLASS"

echo ${CMD}
${CMD}

