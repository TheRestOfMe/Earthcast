#!/bin/bash -l

if [ "$#" -ne 2 ]; then
  echo "echo Usage: ./findnew directory product"
  exit
fi

module load gdal/2.1.2/gcc.4.8.5

procfile="proc"_$2".txt"

echo "doTurb.sh started at $(date)"

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
   '+proj=lcc +lat_1=25 +lat_2=25 +lat_0=25 +lon_0=265 +x_0=0 +y_0=0 +a=6371229 +b=6371229 +units=m +no_defs ' \
   $last -of Gtiff $gsDataDir/ECT_$2_latest_tmp.tiff

# now overwrite existing file
mv  $gsDataDir/ECT_$2_latest_tmp.tiff $gsDataDir/ECT_$2_latest.tiff

# and break out the individual bands
# Do 1K - 50K feet
for b in {2..51}
do
  let x="((b - 1) * 1000)"
  if [ "$b" -lt 11 ]; then
    ft="0$x"
  else
    ft="$x"
  fi
  gdal_translate -b $b $gsDataDir/ECT_$2_latest.tiff -of Gtiff $gsDataDir/ECT_GTGTURB_latest_$ft.tiff
done

# Do 0K ft which is in band 52- is it always?

gdal_translate -b 52 $gsDataDir/ECT_$2_latest.tiff -of Gtiff ECT_GTGTURB_latest_00000.tiff


echo "doTurb.sh finished at $(date)"
