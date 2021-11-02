#!/bin/bash -e

# Batch system directives
#SBATCH  --job-name=run.test_case_site_v3
#SBATCH  --nodes=1
#SBATCH  --output=run.test_case_site_v3.%j 
#SBATCH  --exclusive 
#SBATCH  --constraint=knl,quad,cache

# template to create a case run shell script. This should only ever be called
# by case.submit when on batch. Use case.submit from the command line to run your case.

# cd to case
cd /global/cscratch1/sd/yazbeck/test_case_site_v3

# Set PYTHONPATH so we can make cime calls if needed
LIBDIR=/global/u1/y/yazbeck/E3SM_code/cime/scripts/lib
export PYTHONPATH=$LIBDIR:$PYTHONPATH

# setup environment
source .env_mach_specific.sh

# get new lid
lid=$(python -c 'import CIME.utils; print CIME.utils.new_lid()')
export LID=$lid

# Clean/make timing dirs
RUNDIR=$(./xmlquery RUNDIR --value)
if [ -e $RUNDIR/timing ]; then
    /bin/rm -rf $RUNDIR/timing
fi
mkdir -p $RUNDIR/timing/checkpoints

# minimum namelist action
./preview_namelists --component cpl
#./preview_namelists # uncomment for full namelist generation

# uncomment for lockfile checking
# ./check_lockedfiles

# setup OMP_NUM_THREADS
export OMP_NUM_THREADS=$(./xmlquery THREAD_COUNT --value)

# save prerun provenance?

# MPIRUN!
cd $(./xmlquery RUNDIR --value)
srun  --label  -n 1 -N 1 -c 272   --cpu_bind=cores   -m plane=1 /global/cscratch1/sd/yazbeck/e3sm_scratch/cori-knl/test_case_site_v3/bld/e3sm.exe   >> e3sm.log.$LID 2>&1 

# save logs?

# save postrun provenance?

# resubmit ?
