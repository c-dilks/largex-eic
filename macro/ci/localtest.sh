#!/bin/bash
# sandbox for local tests and development; not executed by CI

# reset
# rm -rv out/*; touch out/.keep

# beam energy
e=10
p=100

# high stats comparisons
fastconfig="datarec/arc/fastS3/10x100/delphes.config"
fullconfig="datarec/deathvalley-v1.0/10x100/files.config"

# loop over recon methods
for recon in ele jb da; do
  root -b -q 'macro/ci/analysis_x_q2.C("'$fastconfig'",'$e','$p',-25,"xq.'$recon'.fastsim","'$recon'")' &
  root -b -q 'macro/ci/analysis_x_q2.C("'$fullconfig'",'$e','$p',-25,"xq.'$recon'.fullsim","'$recon'")' &
  wait
  root -b -q 'macro/ci/comparator.C("out/xq.'$recon'.fastsim.root","out/xq.'$recon'.fullsim.root","out/resolution.fastfull.'$recon'.root")'
  root -b -q 'macro/ci/comparator.C("out/xq.'$recon'.fastsim.root","out/xq.'$recon'.fullsim.root","out/coverage.fastfull.'$recon'.root")'
done
