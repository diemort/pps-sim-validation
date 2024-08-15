#!/bin/sh

# fetching vars
it=$1
seed=$1
cmssw=$2
evts=$3
tag=$4
basearea=$5
xtmin=$6
xtmax=$7
xximin=$8
xximax=$9
xecms=${10}
scram=${11}

# setup cmssw
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=$scram
scram project $cmssw
cd $cmssw/src/
eval `scramv1 runtime -sh`

# prep step1
step=step1
cp ../../step1.py .
label=${step}_${tag}
outfile=${label}_${it}.root
sed -i "s@xfileout@$outfile@g" step1.py
sed -i "s@xseed@$seed@g" step1.py
sed -i "s@xevents@$evts@g" step1.py
sed -i "s@xtmin@$xtmin@g" step1.py
sed -i "s@xtmax@$xtmax@g" step1.py
sed -i "s@xximin@$xximin@g" step1.py
sed -i "s@xximax@$xximax@g" step1.py
sed -i "s@xecms@$xecms@g" step1.py
# run step1
cmsRun step1.py
# prep output
ppseos=${basearea}/fullsim
if [ ! -d "$ppseos/${tag}/${step}" ]; then
    mkdir -p $ppseos/${tag}/${step}
fi
# transfer output files to eos
xrdcp -f $outfile root://eoscms.cern.ch/$ppseos/${tag}/${step}/$outfile

# prep step2
input=${label}_${it}.root
step=step2
cp ../../step2.py .
label=${step}_${tag}
outfile=${label}_${it}.root
sed -i "s@xinput@$input@g" step2.py
sed -i "s@xfileout@$outfile@g" step2.py
sed -i "s@xseed@$1@g" step2.py
# run step2
cmsRun step2.py
if [ ! -d "$ppseos/${tag}/${step}" ]; then
    mkdir -p $ppseos/${tag}/${step}
fi
# transfer output files to eos
xrdcp -f $outfile root://eoscms.cern.ch/$ppseos/${tag}/${step}/$outfile

# prep step3
input=${label}_${it}.root
step=step3
cp ../../step3.py .
label=${step}_${tag}
outfile=${label}_${it}.root
sed -i "s@xinput@$input@g" step3.py
sed -i "s@xfileout@$outfile@g" step3.py
# run step3
cmsRun step3.py
# prep storage
if [ ! -d "$ppseos/${tag}/${step}" ]; then
    mkdir -p $ppseos/${tag}/${step}
fi
# transfer output files to eos
xrdcp -f $outfile root://eoscms.cern.ch/$ppseos/${tag}/${step}/$outfile

# clean working node
cd ../..
rm -rf CMSSW*
rm -rf `whoami`.cc
