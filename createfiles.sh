#!/bin/sh

SIZES="1m 10m 100m 1g 10g 100g 1t 10tb 100tb"
PV="/usr/bin/pv"

for size in $SIZES; do

    # megabytes
    if [[ "$size" == *m ]]; then
        bs=1048576
        c=`echo "$size" | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//'`
        count=$c
        prefix="mb"

    # gigabytes
    elif [[ "$size" == *g ]]; then
        bs=1073741824
        c=`echo "$size" | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//'`
        count=$c
        prefix="gb"

    # terabytes
    elif [[ "$size" == *t ]]; then
        bs=1073741824
        c=`echo "$size" | grep -o -E '[0-9]+' | head -1 | sed -e 's/^0\+//'`
        count="$(($(echo $c)*1024))"
        prefix="tb"
    fi

    f="$prefix-$c.bz2"
    if [ -f "$PV" ]; then
        printf "\ncreating $f\n"
        dd if=/dev/zero bs=$bs count=$count 2>/dev/null | $PV -s $(($(echo $bs)*count))  | bzip2 -9 > $f

    else
        printf "creating $f: "
        t="$(date +%s)"
        dd if=/dev/zero bs=$bs count=$count 2>/dev/null |bzip2 -9 > $f
        t="$(($(date +%s)-t))"
        printf "%02d:%02d:%02d:%02s\n" "$((t/86400))" "$((t/3600%24))" "$((t/60%60))" "$((t%60))"

    fi

done
