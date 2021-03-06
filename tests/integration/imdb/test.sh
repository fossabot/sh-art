#!/usr/bin/env bash

testIMDBBogusID(){
  result=$(dc-imdb -s "BOGUS")
  exit=$?
  dc-tools::assert::equal "bogus ID" "$exit" "$ERROR_ARGUMENT_INVALID"
  dc-tools::assert::equal "$result" ""
}

testIMDBNonExistentID(){
  result=$(dc-imdb -s "tt0000000")
  exit=$?
  dc-tools::assert::equal "bogus ID" "$exit" "$ERROR_NETWORK"
  dc-tools::assert::equal "$result" ""
}

testIMDBData(){
  result=$(dc-imdb -s "tt0000001" | jq -r -c .)
  exit=$?
  dc-tools::assert::equal "$exit" "0"
  dc-tools::assert::equal "$result" '{"title":"Carmencita","original":"Carmencita","picture":"https://m.media-amazon.com/images/M/MV5BZmUzOWFiNDAtNGRmZi00NTIxLWJiMTUtYzhkZGRlNzg1ZjFmXkEyXkFqcGdeQXVyNDE5MTU2MDE@._V1_.jpg","year":"1894","type":"movie","runtime":["1 min"],"ratio":"1.33 : 1","id":"tt0000001","properties":{"SOUND_MIX":"Silent","COLOR":"Black and White","FILM_LENGTH":"15.24 m","NEGATIVE_FORMAT":"35 mm (Eastman)","CINEMATOGRAPHIC_PROCESS":"Kinetoscope","PRINTED_FILM_FORMAT":"35 mm"}}'
}

testIMDBImage(){
  filename="$(portable::mktemp dc::http::request)"
  dc-imdb -s --image=dump "tt0000001" > "$filename"
  exit=$?
  dc-tools::assert::equal "$exit" "0"
  fileinfo="$(file -b "$filename")"

  dc-tools::assert::equal "${fileinfo%%,*}" "JPEG image data"
}
