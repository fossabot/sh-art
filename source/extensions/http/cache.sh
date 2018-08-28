#!/usr/bin/env bash

dc-ext::http::request-cache(){
  local url=$1
  local method=$2
  dc-ext::sqlite::select "dchttp" "content" "method='$method' AND url='$url'"
  DC_HTTP_CACHE=miss
  if [ ! "$result" ]; then
    dc::http::request "$url" GET
    if [ "$DC_HTTP_STATUS" != 200 ]; then
      dc::logger::error "Failed fetching for $url"
      exit $ERROR_NETWORK
    fi
    if [ "$DC_HTTP_STATUS" == 200 ]; then
      result="$(cat $DC_HTTP_BODY | base64)"
      dc-ext::sqlite::insert "dchttp" "url, method, content" "'$url', '$method', '$result'"
      DC_HTTP_BODY="$result"
      # "$(cat $DC_HTTP_BODY)"
    fi
  else
    DC_HTTP_STATUS=200
    DC_HTTP_CACHE=hit
    DC_HTTP_BODY="$result" # $(echo $result | base64 -D)"
  fi

}
