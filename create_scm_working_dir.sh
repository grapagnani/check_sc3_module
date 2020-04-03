#!/bin/bash

# scm is SeisComP3 monitor module.
# I configured it to write the status file inside /dev/shm/scm
# However it does not create the directory itselfs

# Created by G.Rapagnani - Royal Observatory of Belgium

export LANG='C' TZ='UTC'
export PATH='/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin'

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
        fi
    else
        echo -n "Config option \"$search_key\" not found inside " >&2
        echo "\"$scm_config_file\"" >&2
    fi
else
    echo "No scm.cfg config file found" >&2
fi
