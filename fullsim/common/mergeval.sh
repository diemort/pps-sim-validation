#!/bin/bash

# replace fullsim <> directsim
sim=$1
label=$2
cmssw=$3
basearea=$4
scram=$5

# prep cmssw
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=$scram
scram project $cmssw
cd $cmssw/src/
eval `scramv1 runtime -sh`

# prep files
ppseos=${basearea}/${sim}
outfile=${sim}_${label}.root
if [ $sim == fullsim ]; then
    step=step3
elif [ $sim == directsim ]; then
    step=step4
else:
    echo "Wrong step"
    break
fi
if [ ${label} != "" ]; then
    step=${label}/${step}
fi
list_files=`ls ${ppseos}/${step}/*|awk '{printf("file:%s,",$1)}' | sed -e's/,$//'`
echo $list_files
cp ../../merge.py .
cmsRun merge.py inputFiles=$list_files outputFile=$outfile
xrdcp -f $outfile root://eoscms.cern.ch/${ppseos}/${outfile}
# validator
# g++ -O3 -o validator validator.cc `root-config --cflags --libs --ldflags` -L./lib/ -lboost_program_options
echo "Starting validation procedure"
valid=${sim}_${label}_Validation.root
cp ../../libboost.tar.gz .
tar zxvf libboost.tar.gz
cp ../../validator .
# options
# s: fullsim or directsim
# y: 2022 (14TeV) or 2021 (13.6TeV) or 2016-17-18 (13 TeV)
./validator --i ${outfile} --o ${valid} --s ${sim} --y 2022
xrdcp -f ${valid} root://eoscms.cern.ch/${ppseos}/${valid}

# clean area
cd ../..
rm -rf CMSSW*
rm -rf `whoami`.cc
