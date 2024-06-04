#!/bin/sh

# setup cmssw
source /cvmfs/cms.cern.ch/cmsset_default.sh
export SCRAM_ARCH=slc7_amd64_gcc10
#export EOS_MGM_URL=root://eoscms.cern.ch
cmssw=$2
scram project $cmssw
cd $cmssw/src/
eval `scramv1 runtime -sh`
# prep config
step=step1
cp ../../step1.py .
# fetching vars
it=$1
seed=$1
evts=$3
tag=$4
basearea=$5
xtmin=$6
xtmax=$7
xximin=$8
xximax=$9
xecms=${10}
# setting up files
label=${step}_${tag}
outfile=${label}_${it}.root
# prep step1
sed -i "s/xfileout/$outfile/g" step1.py
sed -i "s/xseed/$seed/g" step1.py
sed -i "s/xevents/$evts/g" step1.py
sed -i "s/xtmin/$xtmin/g" step1.py
sed -i "s/xtmax/$xtmax/g" step1.py
sed -i "s/xximin/$xximin/g" step1.py
sed -i "s/xximax/$xximax/g" step1.py
sed -i "s/xecms/$xecms/g" step1.py
# run step1
cmsRun step1.py
# prep output
# CHANGING TO DIRECTSIM
ppseos=${basearea}/directsim
if [ ! -d "$ppseos/${tag}/${step}" ]; then
    mkdir -p $ppseos/${tag}/${step}
fi
# transfer output files to eos
#chown matheusp $outfile
xrdcp -f $outfile $ppseos/${tag}/${step}/$outfile

# prep step2
input=${label}_${it}.root
step=step2
cp ../../step2.py .
label=${step}_${tag}
outfile=${label}_${it}.root
sed -i "s?xinput?$input?" step2.py
sed -i "s/xfileout/$outfile/g" step2.py
sed -i "s/xseed/$1/g" step2.py
# run step2
cmsRun step2.py
if [ ! -d "$ppseos/${tag}/${step}" ]; then
    mkdir -p $ppseos/${tag}/${step}
fi
# transfer output files to eos
#chown matheusp $outfile
xrdcp -f $outfile $ppseos/${tag}/${step}/$outfile

# prep step3
input=${label}_${it}.root
step=step3
cp ../../step3.py .
label=${step}_${tag}
outfile=${label}_${it}.root
sed -i "s?xinput?$input?" step3.py
sed -i "s/xfileout/$outfile/g" step3.py
# run step3
cmsRun step3.py
# prep storage
if [ ! -d "$ppseos/${tag}/${step}" ]; then
    mkdir -p $ppseos/${tag}/${step}
fi
# transfer output files to eos
#chown matheusp $outfile
xrdcp -f $outfile $ppseos/${tag}/${step}/$outfile

#INCLUDING STEP4 NEW CHANGES
# prep step4
input=${label}_${it}.root
step=step4
cp ../../step4.py .
label=${step}_${tag}
outfile=${label}_${it}.root
sed -i "s?xinput?$input?" step4.py
sed -i "s/xfileout/$outfile/g" step4.py
# run step4
cmsRun step4.py
# prep storage
if [ ! -d "$ppseos/${tag}/${step}" ]; then
    mkdir -p $ppseos/${tag}/${step}
fi
# transfer output files to eos
#chown matheusp $outfile
xrdcp -f $outfile $ppseos/${tag}/${step}/$outfile


# clean working node
cd ../..
rm -rf CMSSW*
