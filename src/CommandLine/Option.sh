# Usage:
# CommandLine.Option.define_pair -a/--apple:"Some message" -b/--banana -c/--cherry
# CommandLine.Option.define_switch -s/--status -l --help
# CommandLine.Option.show_manual
# CommandLine.Option.get_value -a
# CommandLine.Option.is_on --status

# Define global variable
declare -g _BASHERT_GLOBAL_COMMANDLINE_OPTION_STATUS=false
# ([-args]="-args/--argument" [--argment]="-args/--argument")
declare -Ag _BASHERT_GLOBAL_COMMANDLINE_OPTION_SWITCH_MAP=()
declare -Ag _BASHERT_GLOBAL_COMMANDLINE_OPTION_PAIR_MAP=()
# ([-args/--argment]="$message")
declare -Ag _BASHERT_GLOBAL_COMMANDLINE_OPTION_SWITCH_MANUAL_MAP=()
declare -Ag _BASHERT_GLOBAL_COMMANDLINE_OPTION_PAIR_MANUAL_MAP=()
# ([-args/--argument]="$value")
declare -Ag _BASHERT_GLOBAL_COMMANDLINE_OPTION_SWITCH_VALUE_MAP=()
declare -Ag _BASHERT_GLOBAL_COMMANDLINE_OPTION_PAIR_VALUE_MAP=()

declare -ag _BASHERT_GLOBAL_COMMANDLINE_OPTION_OTHER_VALUE_LIST=()

declare -g _BASHERT_GLOBAL_COMMANDLINE_OPTION_HAS_OTHER=false

# Need to define first, I don't know why
declare -g BASH_ARGV

# Helper function
generate_global_variable() {
    local map_name
    local manual_name
    if [[ "$1" == "pair" ]]; then
        map_name=_BASHERT_GLOBAL_COMMANDLINE_OPTION_PAIR_MAP
        manual_name=_BASHERT_GLOBAL_COMMANDLINE_OPTION_PAIR_MANUAL_MAP
        shift
    elif [[ "$1" == "switch" ]]; then
        map_name=_BASHERT_GLOBAL_COMMANDLINE_OPTION_SWITCH_MAP
        manual_name=_BASHERT_GLOBAL_COMMANDLINE_OPTION_SWITCH_MANUAL_MAP
        shift
    fi

    local i
    local message
    for i in "$@"; do
        if [[ "$i" == *:* ]]; then
            message=${i#*:}
            i=${i%%:*}
        fi

        eval "$manual_name"'[$i]="$message"'

        if [[ "$i" == */* ]]; then
            eval "$map_name"'[${i%\/*}]="$i"'
            eval "$map_name"'[${i#*\/}]="$i"'
        else
            eval "$map_name"'[$i]="$i"'
        fi
        message=""
    done
}

# get the commandline argument
get_options() {
    #declare -a options=()
    #local i
    #for ((i=${#BASH_ARGV[@]}-1; i >= 0; i--)); do
    #    options+=( "${BASH_ARGV[$i]}" )
    #done
    #ret ( "${options[@]}" )
    ret ( "${SEASHELL_COMMAND_LINE_ARGUMENT[@]}" )
}

get_others() {
    if ! $_BASHERT_GLOBAL_COMMANDLINE_OPTION_STATUS; then
        var options=( "`get_options`" )
        parse_option "${options[@]}"
    fi
    ret ( "${_BASHERT_GLOBAL_COMMANDLINE_OPTION_OTHER_VALUE_LIST[@]}" )
}

# Parsing the commandline argument
parse_option() {
    local pair_index_name
    local swtich_index_name

    while [ $# -gt 0 ]; do
        pair_index_name="${_BASHERT_GLOBAL_COMMANDLINE_OPTION_PAIR_MAP[$1]}"
        switch_index_name="${_BASHERT_GLOBAL_COMMANDLINE_OPTION_SWITCH_MAP[$1]}"

        if [ -n "$pair_index_name" ]; then
            # pair
            shift
            _BASHERT_GLOBAL_COMMANDLINE_OPTION_PAIR_VALUE_MAP[$pair_index_name]="$1"
            if [ -z "$1" ]; then
                show_manual
            fi 
            shift
        elif [ -n "$switch_index_name" ]; then
            # switch
            shift
            _BASHERT_GLOBAL_COMMANDLINE_OPTION_SWITCH_VALUE_MAP[$switch_index_name]=1
        else
            _BASHERT_GLOBAL_COMMANDLINE_OPTION_OTHER_VALUE_LIST+=("$1")
            shift
        fi
    done

    _BASHERT_GLOBAL_COMMANDLINE_OPTION_STATUS=true
}

# CommandLine.Option.define_pair -a/--apple -b/--banana -c/--cherry
# Define the commandline pair argument
define_pair() {
    generate_global_variable "pair" "$@"
}

# CommandLine.Option.define_switch -s/--status -l/--list
# Define the commandline switch argument
define_switch() {
    generate_global_variable "switch" "$@"
}

# Define commandline has other argument
define_others() {
    _BASHERT_GLOBAL_COMMANDLINE_OPTION_HAS_OTHER=true
}

# Get the commandline pair value
get_value() {
    if ! $_BASHERT_GLOBAL_COMMANDLINE_OPTION_STATUS; then
        var options=( "`get_options`" )
        parse_option "${options[@]}"
    fi

    local key="${_BASHERT_GLOBAL_COMMANDLINE_OPTION_PAIR_MAP[$1]}"
    if [ -n "$key" ]; then
        ret "${_BASHERT_GLOBAL_COMMANDLINE_OPTION_PAIR_VALUE_MAP[$key]}"
    fi
    ret ""
}

# Get the commandline switch value
is_on() {
    if ! $_BASHERT_GLOBAL_COMMANDLINE_OPTION_STATUS; then
        var options=( "`get_options`" )
        parse_option "${options[@]}"
    fi

    local key="${_BASHERT_GLOBAL_COMMANDLINE_OPTION_SWITCH_MAP[$1]}"
    if [ -n "$key" ]; then
        ret "${_BASHERT_GLOBAL_COMMANDLINE_OPTION_SWITCH_VALUE_MAP[$key]}"
    fi
    ret ""
}

# Display the manual
show_manual() {
    local other_message=""
    if $_BASHERT_GLOBAL_COMMANDLINE_OPTION_HAS_OTHER; then other_message="others ..."; fi
    local message
    echo "Usage: `basename "${BASH_SOURCE[-1]}"` [option [argument]] $other_message"
    echo "Options:"
    for i in "${!_BASHERT_GLOBAL_COMMANDLINE_OPTION_PAIR_MANUAL_MAP[@]}"; do
        message="${_BASHERT_GLOBAL_COMMANDLINE_OPTION_PAIR_MANUAL_MAP[$i]}"
        echo "    $i ARGS${message:+: $message}"
    done
    for i in "${!_BASHERT_GLOBAL_COMMANDLINE_OPTION_SWITCH_MANUAL_MAP[@]}"; do
        message="${_BASHERT_GLOBAL_COMMANDLINE_OPTION_SWITCH_MANUAL_MAP[$i]}"
        echo "    $i${message:+: $message}"
    done
    exit 0
}
