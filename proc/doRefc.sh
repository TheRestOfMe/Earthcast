#!/bin/bash -l

if [ "$#" -ne 2 ]; then
  echo "echo Usage: ./doRefc directory"
  exit
fi

module load gdal/2.1.2/gcc.4.8.5

procfile="proc"_$2".txt"

echo "doRefc.sh started at $(date)"

#check msot recent file against last processed - exit if they are the same
lastProc=($(cat $procfile))
last=($(ls -t $1/*$2*.grb2 | head -1))

echo "Proc last = $lastProc"
echo "last = $last"

if [ "$lastProc" = "$last" ]; then
  echo "No New file.  Exiting"
  exit
fi

echo "New file is $last"
echo $last > $procfile

# We have new turb file- warp it (using tmp file to avoid highly unlikely conflict

gsDataDir=$HOME/gs/data_dir/data/ect/$2

# EPSG:3857
gdalwarp -t_srs EPSG:3857 -s_srs \
   '+proj=longlat +a=6367470 +b=6367470 +no_defs ' \
   $last -of Gtiff $gsDataDir/ECT_$2_latest_tmp.tiff

# now overwrite existing file
mv  $gsDataDir/ECT_$2_latest_tmp.tiff $gsDataDir/ECT_$2_latest.tiff

echo "doRefc.sh finished at $(date)"
