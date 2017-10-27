#!/bin/bash -l

if [ "$#" -ne 2 ]; then
  echo "echo Usage: ./findnewTurb directory product"
  exit
fi

module load gdal/2.1.2/gcc.4.8.5

procfile="proc"_$2".txt"
proctmp=$procfile"_tmp"

echo $(date)
files=($(find $1/*$2*.grb2 -type f -newermt '30 minutes ago' )) #-printf "%T+t%p\n"))
for f in "${files[@]}"
do
  proc=$(grep $f $procfile)
  echo "proc=" $proc
#  if [ ${#proc} -eq 0 ]; then
    echo "    new file: " $f
    # append file to prod_proc.txt 
    echo $f >> $procfile    
    
    # Skipping EPSG:4326 for now
    # output from gdal to prod_latest.gtiff
    #gdalwarp -t_srs EPSG:4326 -s_srs \
    #   '+proj=lcc +lat_1=25 +lat_2=25 +lat_0=0 +lon_0=265 +x_0=0 +y_0=0 +a=6367470 +b=6367470 +units=m +no_defs '\
    #   $f -of Gtiff /home/tcook/gs/data_dir/data/ect/$2/ECT_$2_latest_tmp.tiff
    
    # now overwrite existing file  
    #mv  /home/tcook/gs/data_dir/data/ect/$2/ECT_$2_latest_tmp.tiff \
    #	 /home/tcook/gs/data_dir/data/ect/$2/ECT_$2_latest.tiff
 
    # EPSG:3857
    gdalwarp -t_srs EPSG:3857 -s_srs \
       '+proj=lcc +lat_1=25 +lat_2=25 +lat_0=25 +lon_0=265 +x_0=0 +y_0=0 +a=6371229 +b=6371229 +units=m +no_defs ' \
       $f -of Gtiff /home/tcook/gs/data_dir/data/ect/$2/ECT_$2_latest_tmp.tiff

    # now overwrite existing file
    mv  /home/tcook/gs/data_dir/data/ect/$2/ECT_$2_latest_tmp.tiff \
         /home/tcook/gs/data_dir/data/ect/$2/ECT_$2_latest.tiff

    # limit size of proc.txt- only need to keep a few really, so experiment with this 
    tail -10 $procfile > $proctmp
    cp $proctmp $procfile
#  fi
done
