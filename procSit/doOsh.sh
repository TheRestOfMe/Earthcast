#!/bin/bash -l

if [ "$#" -ne 2 ]; then
  echo "echo Usage: ./doOsh directory product"
  exit
fi

procfile="procOsh"_$2".txt"

echo "doOsh.sh started at $(date)"

#check msot recent file against last processed - exit if they are the same
lastProc=($(cat $procfile))
last=($(ls -t $1/*$2*.grb2 | head -1 | xargs -n1 basename))

echo "Proc last = $lastProc"
echo "last = $last"

if [ "$lastProc" = "$last" ]; then
  echo "No New file.  Exiting"
  exit
fi

echo "New file is $last"
echo $last > $procfile

# We have new mesh/nldn file- copy it to the osh data subdir...
# FIX ME
oshDataDir=$HOME/osh/faSit/data/$2

cp  $1/$last $oshDataDir/tmp.grb2
mv $oshDataDir/tmp.grb2 $oshDataDir/$last

echo "doOsh.sh finished at $(date)"
