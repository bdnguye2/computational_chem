#!/bin/bash


# moves coord files in 2200K and 3200K trajectories
for i in {2..10};
    do for j in {1,2,3};
       do tmp2=$(echo $i - 1 | bc);
          #echo $tmp2;
          tmp1=$(echo $j + $tmp2*3.| bc);
          echo $tmp1;
          cp ../../init_2200K/vel_$i/coord_$j $tmp1;
       done;
    done

for i in {1..10};
    do for j in {1,2,3};
       do tmp2=$(echo $i - 1 | bc);
          #echo $tmp2;
          tmp1=$(echo $j + $tmp2*3. + 30| bc);
          echo $tmp1;
          cp ../../init_3200K/vel_$i/coord_$j $tmp1;
       done;
    done

# renames each coord_{1,2,3} file to coord
for i in {3..60};
    do cd $i;
       mv coord* coord;
       cd ../;
    done
