#!/usr/bin/awk --file

function trim(str) {
    # Remove leading and trailing whitespaces
    gsub(/^\s*/, "", str)
    gsub(/\s*$/, "", str)
    return str
}

BEGIN {
    FS = "|"
    OFS = ","
}

# Video link:
/^-/ {
    if (NF != 2) {
        print "Check line", NR > "/dev/stderr"
        exit 1
    }

    first = substr($1, 2)

    record_name = first
    yt_url = $2

    record_name = trim(record_name)
    yt_url = trim(yt_url)
}

# Sample snippet:
!/^-/ && !/^$/ {
    if (NF != 2) {
        print "Check line", NR > "/dev/stderr"
        exit 2
    }

    # TODO: record_name and yt_url check.

    timestamps_string = $1 # Like "0:12 - 0:19"
    sample_name = $2

    timestamps_string = trim(timestamps_string)
    sample_name = trim(sample_name)

    if (split(timestamps_string, timestamps, "-") != 2) {
        print "Check line", NR > "/dev/stderr"
        exit 3
    }

    for (i in timestamps) {
        timestamps[i] = trim(timestamps[i])
    }

    filename = record_name "__" sample_name
    gsub(/ /, "_", filename)

    # Output format: filename, youtube url, start timestamp, end timestamp
    print filename, yt_url, timestamps[1], timestamps[2]
}
