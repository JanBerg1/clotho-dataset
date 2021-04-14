#!/bin/bash

SAMPLE_RATE=44100

# fetch_clip(videoID, startTime, endTime)
fetch_clip() {
  #echo "Fetching $1 ($2 to $3)..."
  echo "${@:4}"
  outname="$1"
  #echo $(($3+10))
  if [ -f "${outname}.wav.gz" ]; then
    echo "Already have it."
    return
  fi

  youtube-dl https://youtube.com/watch?v=$2 \
    --quiet --extract-audio --audio-format wav \
    --output "$outname.%(ext)s"
  if [ $? -eq 0 ]; then
    # If we don't pipe `yes`, ffmpeg seems to steal a
    # character from stdin. I have no idea why.
    yes | ffmpeg -loglevel quiet -i "./$outname.wav" -ar $SAMPLE_RATE -ac 1\
      -ss "$3" -to "$(($3+10))" "./${outname}_out.wav" 
    mv "./${outname}_out.wav" "./$outname.wav"
    echo "${outname}.wav,${@:4}" >> captions.csv
  else
    # Give the user a chance to Ctrl+C.
    sleep 1
  fi
}

touch captions.csv
echo "file_name,caption_1" >> captions.csv

grep -E '^[^#]' | while read line
do
  #echo "$line"
  fetch_clip $(echo "$line" | sed -E 's/,/ /g')
done
