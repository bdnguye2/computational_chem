#!/bin/bash

for i in {4..60};
    do cp def.inp run_slurm.turbomole $i;
       cd $i;
       sed -i 's/vel_1/vel_'$i'/' run_slurm.turbomole;
       define < ../def.inp;
       sed -i '/$title/i \$surface_hopping \n$nacme \n$exopt 1' control
       mdprep < ../md.inp;
       echo 'md prep done';
       sed -i '/gridsize /a \   weight derivatives' control;
       sed -i '/$nstep/i \$surface_hopping \n$gap_threshold 0.5' mdmaster;
       cd ..;
    done
