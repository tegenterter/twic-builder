#!/bin/bash
readonly URL='https://theweekinchess.com/twic'
readonly REGEX='https?://(www\.)?theweekinchess\.com/zips/twic\d+g?\.zip'

# Create temporary folder for downloads
mkdir -p tmp

master=""

while read -r url ; do
  echo "Processing $url..."

  # Extract database name
  name=$(basename $url .zip | sed 's/g$//')

  # Download, extract and remove ZIP archive
  curl -so tmp/$name.zip $url
  unzip -qq tmp/$name.zip -d "tmp"
  rm -f tmp/$name.zip

  # Append single database contents to the master database
  cat tmp/$name.pgn >> twic.pgn

  if [ -z "$master" ]; then
    master="$name.pgn"
  fi

  # Remove single database
  rm -f tmp/$name.pgn
done <<< "$(curl -sL $URL | egrep -o $REGEX | awk '!a[$0]++')"

# Rename database to reflect the latest update
mv twic.pgn "$master"

rm -rf tmp
