#!/bin/bash

source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc7_amd64_gcc10
cmssw=$3
scram project $cmssw
cd $cmssw/src/
eval `scramv1 runtime -sh`
scram b -j8
# replace fullsim <> directsim
sim=$1
ppseos=/eos/cms/store/group/phys_pps/sim-validation/${sim}
outfile=${sim}_${2}.root
if [ $sim == fullsim ]; then
    step=step3
elif [ $sim == directsim ]; then
    step=step4
else:
    echo "Wrong step"
    break
fi
if [ $2 != "" ]; then
    step=${2}/${step}
fi
list_files=`ls ${ppseos}/${step}/*|awk '{printf("file:%s,",$1)}' | sed -e's/,$//'`
echo $list_files
cp ../../merge.py .
cmsRun merge.py inputFiles=$list_files outputFile=$outfile
rsync -avPz $outfile ${ppseos}/${outfile}
cd ../..
rm -rf CMSSW*
