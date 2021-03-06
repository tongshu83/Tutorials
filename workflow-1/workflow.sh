#!/bin/bash
set -eu

# WORKFLOW SH
# Main user entry point

if [[ ${#} != 1 ]]
then
  echo "Usage: ./workflow.sh EXPERIMENT_ID"
  exit 1
fi
export EXPID=$1

# Turn off Swift/T debugging
export TURBINE_LOG=0 TURBINE_DEBUG=0 ADLB_DEBUG=0

# Find my installation directory
export EMEWS_PROJECT_ROOT=$( cd $( dirname $0 ) ; /bin/pwd )

# Set the output directory
export TURBINE_OUTPUT=$EMEWS_PROJECT_ROOT/experiments/$EXPID
mkdir -pv $TURBINE_OUTPUT
cp heat_transfer.xml $TURBINE_OUTPUT/heat_transfer.xml

# Total number of processes available to Swift/T
# Of these, 2 are reserved for the system
export PROCS=48
export PPN=16

export WALLTIME=00:03:00

# EMEWS resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

#export PYTHONPATH=$HOME/sfw/swift-t/turbine/py
export PYTHONPATH=$HOME/software/swift-t/turbine/py
# mlrMBO settings
PARAM_SET_FILE=$EMEWS_PROJECT_ROOT/data/params.R
MAX_CONCURRENT_EVALUATIONS=2
MAX_ITERATIONS=10

# Benchmark settings
BENCHMARK_TIMEOUT=${BENCHMARK_TIMEOUT:-3600}

# Construct the command line given to Swift/T
CMD_LINE_ARGS=( -pp=$MAX_CONCURRENT_EVALUATIONS
                -it=$MAX_ITERATIONS
                -param_set_file=$PARAM_SET_FILE
              )

EQR=$EQR_HOME
#EQR=$EMEWS_PROJECT_ROOT/EQ-R
#LAUNCH=$HOME/proj/mls/src

# USER: set the R variable to your R installation
#R=$HOME/software/R-3.5.1/lib64/R
R=/home/wozniak/Public/sfw/blues/R-3.4.3/lib64/R
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$R/lib:$R/library/Rcpp/libs:$R/library/RInside/lib:$R/library/RInside/libs
#R=$HOME/Public/sfw/R-3.4.3/lib/R
#export LD_LIBRARY_PATH=$R/lib:$R/library/Rcpp/lib:$R/library/RInside/lib:$HOME/sfw/evpath/lib
MACHINE="-m pbs"

export X=3

ENVS="-e LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/software/gcc-4.7.2/lib64 -e R_HOME=$R_HOME -e X"
echo R_HOME $R_HOME
set -x
swift-t -l $MACHINE -p -n $PROCS \
    -I $EQR -r $EQR $ENVS \
    $EMEWS_PROJECT_ROOT/workflow.swift ${CMD_LINE_ARGS[@]}
#        -I $EQR -r $EQR -I $LAUNCH -r $LAUNCH $ENVS \

echo WORKFLOW COMPLETE.

