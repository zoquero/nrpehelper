#!/bin/bash
#
# Sample NRPE script that returns perfdata
#
# Usage: ./simple_nrpe_plugin_with_perfdata.sh data happy_warn happy_crit
#
# Some executions:
# 
# $ ./simple_nrpe_plugin_with_perfdata.sh 96 90 80 ; echo $?
# OK: People seem happy|'Happy people'=96%;90;80;;
# 0
# $ ./simple_nrpe_plugin_with_perfdata.sh 86 90 80 ; echo $?
# WARNING: Too few happy people|'Happy people'=86%;90;80;;
# 1
# $ ./simple_nrpe_plugin_with_perfdata.sh 76 90 80 ; echo $?
# CRITICAL: Too few happy people|'Happy people'=76%;90;80;;
# 2
# 
# zoquero@gmail.com
# 20230711
#

##############
# Some globals
##############
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

###########
# Functions
###########
print_usage() {
    echo "Usage:"
    echo "       $0 data happy_warn happy_crit"
    echo "       $0 --help"
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
happy_warn=$2
happy_crit=$3

if ! [[ "$data" =~ ^[0-9]+$ ]] || \
   ! [[ "$happy_warn" =~ ^[0-9]+$ ]] || \
   ! [[ "$happy_crit" =~ ^[0-9]+$ ]]; then
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

# More complex calculus:
happy_people_metric_label='Happy people'
let happy_people_metric_value=$data
happy_people_metric_units='%'

perfdata="|'$happy_people_metric_label'=$happy_people_metric_value$happy_people_metric_units;$happy_warn;$happy_crit;;"

################
# Regular return
################

if [ $data -lt $happy_crit ]; then
  echo "CRITICAL: Too few happy people$perfdata"
  exit $STATE_CRITICAL
elif [ $data -lt $happy_warn ]; then
  echo "WARNING: Too few happy people$perfdata"
  exit $STATE_WARNING
else
  echo "OK: People seem happy$perfdata"
  exit $STATE_OK
fi
