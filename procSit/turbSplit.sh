#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "echo Usage: ./turbSplit.sh inffile" 
  exit
fi


# Do 1K - 50K feet
for b in {2..51}
do
  let x="((b - 1) * 1000)"
  if [ "$b" -lt 11 ]; then
    ft="0$x"
  else
    ft="$x"
  fi
  gdal_translate -b $b $1 -of Gtiff ECT_GTGTURB_latest_$ft.tiff
done

# Do 0K ft which is in band 52- is it always?

gdal_translate -b 52 $1 -of Gtiff ECT_GTGTURB_latest_00000.tiff
