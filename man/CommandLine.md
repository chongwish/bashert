# CommandLine

## Option

Define all the parameters.

```bash
use CommandLine.Option [ define_pair define_switch ]
    
define_switch -s/--status -h/--help:"Display the manual" -l:"List all things"

define_pair -a/--apple:"What color apple do you want?" -b/--banana -c/--cherry
```

Generate the manual and show it:

```bash
use CommandLine.Option [ show_manual ]

show_manual
```

The result will be like:

```
Usage: example.sh [option [argument]]
Options:
    -a/--apple ARGS: What color apple do you want?
    -b/--banana ARGS
    -c/--cherry ARGS
    -s/--status
    -l: List all things
    -h/--help: Display the manual
```

You can get the value from the commandline `bash example.sh -a red --status`:

```bash
use CommandLine.Option [ get_value is_on ]

get_value --apple
is_on -s
```

Here is the full example:

```bash
# file: bin/example

use CommandLine.Option [ get_options define_pair define_switch get_value is_on show_manual ]

execute() {
    define_switch \
        -s/--status \
        -h/--help:"Display the manual" \
        -l:"List all things"

    define_pair \
        -a/--apple:"What color apple do you want?" \
        -b/--banana \
        -c/--cherry
    
    var apple="`get_value --apple`"
    if [ -n "$apple" ]; then
        echo "I want $apple apple!"
    else
        show_manual
    fi

    var status="`is_on --status`"
    if [ -n "$status" ]; then
        echo "OK"
    else
        echo "NO"
    fi
}
```