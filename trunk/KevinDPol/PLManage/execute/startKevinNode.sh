#!/bin/bash

# This script allows to launch Simple Gossip executor
#
# Usage: command bootstrap_name:bootstrap_port port timestamp

# creating the bootstrapset file from these info (no need to redeploy the whole thing when changing the bootstrap)
# Everything is set in the boostrap as it is the first script to be run

source ../configure.sh

#alpha=`myrand 0.65 0.70`

beta=$BETA

function launch () {
	GOSSIP_PORT=$(($GOSSIP_PORT+$1))
#    ssh -o ConnectTimeout=$SSH_TIMEOUT -o StrictHostKeyChecking=no ${LOGIN_NAME}@$node "cd /tmp; echo $BOOTSTRAP $BOOTSTRAP_PORT 0 > package/bootstrapset.txt; /tmp/package/jre/bin/java -classpath package/$PROJECT_NAME/bin $NODELAUNCHERCLASSNAME -fileName $node$date.out -bset package/bootstrapset.txt -name $node -port $GOSSIP_PORT -alpha 0.7 -beta 1 -decision 0.3 -nbGroups $NB_GROUPS"
##changed this to simply perform the operations on localhost without needing ssh
cd /tmp; echo $BOOTSTRAP $BOOTSTRAP_PORT 0 > package/bootstrapset.txt; /tmp/package/jre/bin/java -classpath package/$PROJECT_NAME/bin $NODELAUNCHERCLASSNAME -fileName $node$date.out -bset package/bootstrapset.txt -name $node -port $GOSSIP_PORT -alpha 0.7 -beta 1 -decision 0.3 -nbGroups $NB_GROUPS

}

function launch2 () {
	GOSSIP_PORT=$(($GOSSIP_PORT+$1))
#    ssh -o ConnectTimeout=$SSH_TIMEOUT -o StrictHostKeyChecking=no ${LOGIN_NAME}@$node "cd /tmp; echo $BOOTSTRAP $BOOTSTRAP_PORT 0 > package/bootstrapset.txt; /tmp/package/jre/bin/java -classpath package/$PROJECT_NAME/bin $NODELAUNCHERCLASSNAME -fileName $node$date.out -bset package/bootstrapset.txt -name $node -port $GOSSIP_PORT -alpha 0.7 -beta 0 -decision 0.3 -nbGroups $NB_GROUPS"
##changed this to simply perform the operations on localhost without needing ssh
cd /tmp; echo $BOOTSTRAP $BOOTSTRAP_PORT 0 > package/bootstrapset.txt; /tmp/package/jre/bin/java -classpath package/$PROJECT_NAME/bin $NODELAUNCHERCLASSNAME -fileName $node$date.out -bset package/bootstrapset.txt -name $node -port $GOSSIP_PORT -alpha 0.7 -beta 0 -decision 0.3 -nbGroups $NB_GROUPS

}

if [ $# -ne 4 ]
then
   echo -e "\e[35;31mNot enough arguments provided"; tput sgr0 # magenta
   exit 1;
else
   nodesFile=$1

   if [[ `expr $2 : "[a-zA-Z.]*:[0-9]*"` ]]
   then
      BOOTSTRAP_PORT=${2#*:}
      echo port: $BOOTSTRAP_PORT
      BOOTSTRAP=${2%:*}
      echo bootstrap: $BOOTSTRAP
   else
      BOOTSTRAP=${2%:*}
      echo $BOOTSTRAP
      echo $BOOTSTRAP_PORT
   fi
   GOSSIP_PORT=$3
   sdate=$4
   date="-$sdate"
fi

fileName=`basename $nodesFile`

echo -e "\E[32;32mLaunching the experiment on all nodes"; tput sgr0 # green

i=0
for node in `tac $nodesFile | grep -iv "#" | cut -d ' ' -f 1`
do
   echo 'entered for loop'
   if [ $(($i)) -lt $(($NB_MALICIOUS)) ]
   then
	#echo 'launch'
      launch i &
   else
#	echo 'launch2'
      launch2 i &
   fi
   i=$(($i+1))
done
echo 'exited the loop'
wait

./getOutputs.sh $nodesFile $sdate

sort $nodesFile > $sdate/$fileName

cd $sdate
ls *.out | sed "s/\t/\n/g" | sed "s/$date.out//g" | sort > list
cd ..

exit 0
