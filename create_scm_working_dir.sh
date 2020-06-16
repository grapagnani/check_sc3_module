#!/bin/bash

# scm is SeisComP3 monitor module.
# I configured it to write the status file inside /dev/shm/scm
# However it does not create the directory itselfs

# Created by G.Rapagnani - Royal Observatory of Belgium

export LANG='C' TZ='UTC'
export PATH='/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin'

# Configuration

f_restart_scm=false # restart scm module upon creation of its working directory
seiscomp_cmd="$HOME/seiscomp3/bin/seiscomp"


# Functions

restart_scm() {
    if [ -f "$seiscomp_cmd" -a -x "$seiscomp_cmd" ]; then
        if "$seiscomp_cmd" status scm | grep -q "^scm  *is running"; then
            "$seiscomp_cmd" restart scm >&2
        else
            echo "scm module is not running, so not restarting it." >&2
        fi
    else
        echo "File \"$seiscomp_cmd\" not found/executable" >&2
    fi
}

search_key="mtextplugin.outputDir"

for scm_config_file in "$HOME"/.seiscomp3/scm.cfg \
    "$HOME"/seiscomp3/etc/scm.cfg "$HOME"/seiscomp3/etc/defaults/scm.cfg; do

    [ -f "$scm_config_file" ] && break

done

if [ -f "$scm_config_file" ]; then
    scm_work_dir="$(grep "$search_key" "$scm_config_file" \
        | grep -v "^#" \
        | cut -d "=" -f 2 \
        | sed "s/^  *//;s/  *$//;")"

    if [ -n "$scm_work_dir" ]; then
        if test -d "$scm_work_dir"; then
            echo "Directory \"$scm_work_dir\" already present" >&2
        else
            mkdir -v "$scm_work_dir" >&2
            $f_restart_scm && restart_scm
        fi
    else
        echo -n "Config option \"$search_key\" not found inside " >&2
        echo "\"$scm_config_file\"" >&2
    fi
else
    echo "No scm.cfg config file found" >&2
fi
