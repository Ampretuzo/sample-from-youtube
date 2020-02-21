#!/usr/bin/env bash

if ! command -v youtube-dl 1>/dev/null
then
	echo "Please install youtube-dl first!" 1>&2
	exit 1
fi

function append_video_id {
	awk '
		BEGIN {
			FS=","
			OFS=","
		}

		{
			# Match video id in youtube url query string:
			idx = match($2, /\?v[^&]*/)
			if (idx == 0) {
				printf("Could not extract video id from %s for \"%s\", skipping\n", $2, $1) > "/dev/stderr"
				next
			}
			# +=3 because of "?v" prefix:
			print $0, substr($2, RSTART + 3, RLENGTH - 3)
		}'
}

# NOTE: couldn't I have just deleted temp files with 'sample_from_youtube_downloaded_files_' prefix?
# answer: NO! what about other users who might be downloading samples in parallel (Really???)?
# NOTE: I could also have made per-process unique prefix...
DOWNLOADED_FILES=$(mktemp -t "sample_from_youtube_downloaded_files_XXXXXXX")
trap "(cat $DOWNLOADED_FILES | xargs -r rm) && rm $DOWNLOADED_FILES" EXIT

function download_audio {
	declare -A id_to_file

	while IFS=',' read -ra LINE
	do
		FNAME="${LINE[0]}"
		YT_URL="${LINE[1]}"
		START="${LINE[2]}"
		END="${LINE[3]}"
		YT_ID="${LINE[4]}"

		if test -n "${id_to_file[$YT_ID]}"
		then
			TMPFILE="${id_to_file[$YT_ID]}"
		else
			TMPFILE=$(mktemp -t "sample_from_youtube_${YT_ID}_XXXXX.wav")

			youtube-dl \
				--quiet \
				--no-continue \
				--no-playlist \
				--extract-audio \
				--audio-format wav \
				--audio-quality 0 \
				--output "$TMPFILE" \
				"$YT_URL"
			if test 0 != "$?"
			then
				echo "Downloading $YT_ID complete." 1>&2
				# TODO: handle bad cases later...
			fi

			echo $TMPFILE >> $DOWNLOADED_FILES
			id_to_file[$YT_ID]=$TMPFILE
		fi

		echo $FNAME,$TMPFILE,$START,$END

	done
}

function crop_sample {
	while IFS=',' read -ra LINE
	do
		FNAME="${LINE[0]}"
		AUDIO_FILE="${LINE[1]}"
		START="${LINE[2]}"
		END="${LINE[3]}"

		# TODO: $END needs +1 second.
		ffmpeg \
			-i "$AUDIO_FILE" \
			-ss "$START" \
			-to "$END" \
			-n \
			-loglevel "quiet" \
			"${SAMPLES_DIR}/${FNAME}.wav" \
			2>/dev/null
		if test 0 == $?
		then
			echo "Done: ${FNAME}.wav"
		else
			echo "There was an error with ${FNAME}.wav"
		fi
	done
}

SAMPLES=${SAMPLES:-~/samples}
SAMPLES_DIR=${SAMPLES_DIR:-~/samples.out}
mkdir -p "$SAMPLES_DIR"

./parse.awk $SAMPLES | append_video_id | download_audio | crop_sample
