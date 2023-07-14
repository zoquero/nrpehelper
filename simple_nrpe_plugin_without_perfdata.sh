#!/bin/bash
#
# Sample nrpe script
#
# Usage: ./sample_script.sh data warn_threshold crit_threshold
#
#
# Some executions:
#
# $ ./sample_script.sh 1 3 5 ; echo $?
# OK: data seems fine
# 0
# $ ./sample_script.sh 4 3 5 ; echo $?
# WARNING: data is greater than warn_threshold (4 > 3)
# 1
# $ ./sample_script.sh 6 3 5 ; echo $?
# CRITICAL: data is greater than crit_threshold (6 > 5)
# 2
#
# zoquero@gmail.com
# 20230711
#

############
# Paràmetres
############

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

###########
# Functions
###########
print_usage() {
    echo "Usage:"
    echo "       $0 data warn_threshold crit_threshold"
    echo "       $0 --version"
    echo ""
}

####################
# Some verifications
####################

if [ "$EUID" -eq 0 ]; then
  echo -e "Don't run as root, please.\n"
  print_usage
  exit $STATE_CRITICAL
fi
if [ "$1" = '--help' ]; then
  print_usage
  exit $STATE_CRITICAL
fi
if [ "$#" -lt 3 ]; then
  echo -e "Illegal number of parameters: $#\n"
  print_usage
  exit $STATE_CRITICAL
fi

########
# Params
########
data=$1
warn_threshold=$2
crit_threshold=$3

if ! [[ "$data" =~ ^[0-9]+$ ]] || ! [[ "$warn_threshold" =~ ^[0-9]+$ ]] || ! [[ "$crit_threshold" =~ ^[0-9]+$ ]]; then
  echo -e "args must be integer $#\n"
  print_usage
  exit $STATE_CRITICAL
fi


###########
# Execution
# Extract metrics and generate CRITICAL errors if anything wrong happens
###########

# Complex calculus
let data=data+1
let data=data-1

# Report any error
if [ $data -eq $RANDOM ]; then
  echo "CRITICAL: Something went wrong extracting the metrics"
  exit $STATE_CRITICAL
fi

################
# Regular return
################
if [ $data -gt $crit_threshold ]; then
  echo "CRITICAL: data is greater than crit_threshold ($data > $crit_threshold)"
  exit $STATE_CRITICAL
elif [ $data -gt $warn_threshold ]; then
  echo "WARNING: data is greater than warn_threshold ($data > $warn_threshold)"
  exit $STATE_WARNING
else
  echo "OK: data seems fine"
  exit $STATE_OK
fi
