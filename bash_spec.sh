#!/bin/bash
# Bash spec
#
# Ex:
# Describe $some_function
#     Given I have $string_condition_to_be_evaluated
#     When I use without arguments $args
#     then It should be valid $string_validation_to_be_evaluated
#


#colors
red=`tput setaf 1`
green=`tput setaf 2`
blue=`tput setaf 4`
gray=`tput setaf 8`
reset=`tput sgr0`

test_cout=1
last_bdd_action=none

# Support methods
########

function init_test(){
    test_fail=false
    init_script_data
    ((test_cout++))
    if [ ! -z $SKIP_TEST ] && [[ $SKIP_TEST -lt $test_cout ]]
    then unset SKIP_TEST
    fi
    [ ! -z $SKIP_TEST ] && return || true
    echo
    last_bdd_action=given # to force skip init in step actions
    Background
}

function init_script_data(){
    echo "Please override!!!"
}

function Background(){
    true
}
function Table(){
    true
}
function Row(){
    Table $*
}

function find_method(){
    eval "map_keys=(\"\${!$1[@]}\")"
    eval "map_values=(\"\${$1[@]}\")"
    shift
    unset step_value step_method
    key_with_values=$*
    for i in "${!map_keys[@]}"; do
        if [[ ${key_with_values} =~ ${map_keys[$i]} ]]
            then step_value=${BASH_REMATCH[1]}
                 step_method=${map_values[$i]}
                 return
        fi
    done
    >&2 echo "Not Mapped! ${key_with_values}"
}

function echo_result(){
    result=$1;shift
    if [ "$result" == "true" ] || [ "$result" == "0" ]
        then echo "  ${green}$*${reset}"
    elif $test_fail
        then echo "${gray}  $* SKIP!${reset}"
        else echo "${red}--Error! $*${reset} (test $test_cout)"
             [ -z "${error_detail}" ] || echo "${red}Detail: ${error_detail}${reset}"
             unset error_detail
             test_fail=true
    fi
}

function log_error_detail(){
    error_detail=$*
    false
}

# Verbs handlers
########

function Describe(){
    last_bdd_action=describe
    current_method=$1
    echo
    echo "${blue}> Describe ${current_method}${reset}"
}

declare -A GIVEN_MAP
function Given(){
    [ "$last_bdd_action" != 'given' ] && init_test || true
    last_bdd_action=given
    [ -z $SKIP_TEST ] || return
    find_method GIVEN_MAP $*
    ! $test_fail && $step_method $step_value
    echo_result "$?" "GIVEN $*"
}

declare -A WHEN_MAP
function When(){
    [[ 'describe|then' =~ $last_bdd_action ]] && init_test || true
    last_bdd_action=when
    [ -z $SKIP_TEST ] || return
    find_method WHEN_MAP $*
    ! $test_fail && $step_method $step_value
    echo_result "$?" "WHEN $*"
}

declare -A THEN_MAP
function Then(){
    [ "$last_bdd_action" == 'describe' ] && init_test || true
    last_bdd_action=then
    [ -z $SKIP_TEST ] || return
    find_method THEN_MAP $*
    ! $test_fail && $step_method $step_value
    echo_result "$?" "THEN $*"
}


# Default steps
########

GIVEN_MAP["I have (.*)"]=Given_I_have
Given_I_have(){
    eval $*
    [ $? -eq 0 ] || log_error_detail $(eval echo $*)
}

GIVEN_MAP["I run (.*)"]=Given_I_Run
Given_I_Run(){
    eval $* >/dev/null
    [ $? -eq 0 ] || log_error_detail $(eval echo $*)
}

WHEN_MAP["I use with the arguments (.*)"]=When_I_use_with_the_arguments
When_I_use_with_the_arguments(){
    $current_method $* >/dev/null
}

WHEN_MAP["I use without arguments"]=When_I_use_without_arguments
WHEN_MAP["I run"]=When_I_use_without_arguments
When_I_use_without_arguments(){
    $current_method >/dev/null
}

THEN_MAP["It should be valid (.*)"]=Then_It_Should_be_valid
Then_It_Should_be_valid(){
    eval $*
    [ $? -eq 0 ] || log_error_detail $(eval echo $*)
}
