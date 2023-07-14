#!/bin/bash
#
# Sample NRPE script that returns perfdata with multiple metrics
#
# Usage: ./simple_nrpe_plugin_with_perfdata_multiple_metrics.sh data hungry_warn hungry_crit angry_warn angry_crit
#
# Some executions:
#
# $ ./simple_nrpe_plugin_with_perfdata_multiple_metrics.sh 4 8 14 18 25 ; echo $?
# OK: People seem fine|'Hungry people'=4%;8;14;; 'Angry people'=5%;18;25;;
# 0
# $ ./simple_nrpe_plugin_with_perfdata_multiple_metrics.sh 9 8 14 18 25 ; echo $?
# WARNING: Too many hungry (9) or angry people (10)|'Hungry people'=9%;8;14;; 'Angry people'=10%;18;25;;
# 1
# $ ./simple_nrpe_plugin_with_perfdata_multiple_metrics.sh 23 8 14 18 25 ; echo $?
# CRITICAL: Too many hungry (23) or angry people (24)|'Hungry people'=23%;8;14;; 'Angry people'=24%;18;25;;
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
    echo "       $0 data hungry_warn hungry_crit angry_warn angry_crit"
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
if [ "$#" -lt 5 ]; then
  echo -e "Illegal number of parameters: $#\n"
  print_usage
  exit $STATE_CRITICAL
fi

########
# Params
########
data=$1        # data
hungry_warn=$2 # warning  value for percentage of hungry people
hungry_crit=$3 # critical value for percentage of hungry people
angry_warn=$4  # warning  value for percentage of angry  people
angry_crit=$5  # critical value for percentage of angry  people

if ! [[ "$data"        =~ ^[0-9]+$ ]] || \
   ! [[ "$hungry_warn" =~ ^[0-9]+$ ]] || \
   ! [[ "$hungry_crit" =~ ^[0-9]+$ ]] || \
   ! [[ "$angry_warn"  =~ ^[0-9]+$ ]] || \
   ! [[ "$angry_crit"  =~ ^[0-9]+$ ]]  ; then
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
hungry_people_metric_label='Hungry people'
let hungry_people_metric_value=$data
hungry_people_metric_units='%'

angry_people_metric_label='Angry people'
let angry_people_metric_value=$data+1
angry_people_metric_units='%'

perfdata="|'$hungry_people_metric_label'=$hungry_people_metric_value$hungry_people_metric_units;$hungry_warn;$hungry_crit;;"
perfdata="$perfdata '$angry_people_metric_label'=$angry_people_metric_value$angry_people_metric_units;$angry_warn;$angry_crit;;"

################
# Regular return
################
if [ $hungry_people_metric_value -ge $hungry_crit -o $angry_people_metric_value -ge $angry_crit ]; then
  echo "CRITICAL: Too many hungry ($hungry_people_metric_value) or angry people ($angry_people_metric_value)$perfdata"
  exit $STATE_CRITICAL
elif [ $hungry_people_metric_value -ge $hungry_warn -o $angry_people_metric_value -ge $angry_warn ]; then
  echo "WARNING: Too many hungry ($hungry_people_metric_value) or angry people ($angry_people_metric_value)$perfdata"
  exit $STATE_WARNING
else
  echo "OK: People seem fine$perfdata"
  exit $STATE_OK
fi
