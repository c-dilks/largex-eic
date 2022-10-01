#!/bin/bash
# organize artifacts by combining directories
# - execute in CI pipelines from top-level directory, after all artifacts
#   have been collected into one directory, specified by argument

# arguments
if [ $# -ne 1 ]; then echo "USAGE: $0 [artifacts-dir]"; exit 2; fi
pushd $1

# merge directories of fastsim and fullsim files, for comparison
# - adds `.fastsim` or `.fullsim` suffixes to filenames
echo "------------- merge fastsim and fullsim -------------------"
# loop through *fastsim* directories
ls | grep fastsim |\
while read dirFast; do

  # set fullsim and output directory names
  echo "--------------------"
  dirOut=$(echo $dirFast | sed 's/fastsim//g' | sed 's/__/_/g')
  mkdir -p $dirOut

  # move fastsim artifacts to output directory, and add suffix to file name
  echo "MOVE AND RENAME artifacts in $dirFast -> $dirOut"
  pushd $dirFast
  for file in *; do
    mv -v $file ../$dirOut/$(echo $file | sed 's/^.*\./&fastsim./g')
  done
  popd

  # repeat for fullsim artifacts
  for detector in athena ecce epic; do
    dirFull=$(echo $dirFast | sed "s/fastsim/${detector}/g")
    echo "MOVE AND RENAME artifacts in $dirFull -> $dirOut"
    if [ -d "$dirFull" ]; then
      pushd $dirFull
      for file in *; do
        mv -v $file ../$dirOut/$(echo $file | sed "s/^.*\./&${detector}./g")
      done
      popd
      echo "CLEANUP"
      rm -rv $dirFull
    else
      echo "WARNING: $dirFull does not exist; ignoring"
    fi
  done

  echo "CLEANUP"
  rm -rv $dirFast

done

############
popd
