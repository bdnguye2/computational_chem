#!/bin/bash

# The xyz file must be generated
# Extract the coordinate files from the ground state AIMD simulations
for i in vel_{?,10};
    do cd $i;
       log2x > xyz.out;
       grep -A 9 ' 3400' xyz.out > coord_1.xyz;
       grep -A 9 ' 6800' xyz.out > coord_2.xyz;
       grep -A 9 ' 10200' xyz.out > coord_3.xyz;
       x2t coord_1.xyz > coord_1;
       x2t coord_2.xyz > coord_2;
       x2t coord_3.xyz > coord_3;
       cd ..;
    done
