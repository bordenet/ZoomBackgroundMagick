#!/bin/zsh
SCRIPT=createPanoMovies.sh
trap "killall ffmpeg $SCRIPT;" INT TERM EXIT  # Kill & clean if stopped.

# terminal colors
RED=$'\e[1;31m'
GREEN=$'\e[1;32m'
YELLOW=$'\e[1;33m'
BLUE=$'\e[1;34m'
MAG=$'\e[1;35m'
CYN=$'\e[1;36m'
ENDCOLOR=$'\e[0m'

tmpdir="createPanoMovies_tmp"
intermediateRender="tempPanoMovie.mp4"
finalRender="panoMovie.mp4"

use_hw_accel="no"
do_canonicalize_file_names="no"
do_transpose_images="no"

log_level_ffmpeg="quiet"
sleep_time=360

pixel_slew=1024          # pixels to jump between pan transitions
pan_inc_denominator=1024 # divides pixel_slew time the number of frames in pre-processed mp4
clock_multiplier=1.5     # multiplier we'll apply to presentation times -- to elongate the movie
blurfactor=4             # frames per second in final

#--------------------------------
sleep-between-runs() {
  remainingSleepTime=${sleep_time}
  while [[ ${remainingSleepTime} -gt 0 ]]; do
    sleep 1
    (( remainingSleepTime = $remainingSleepTime - 1 ))
    echo -ne "\rSleeping for ${remainingSleepTime} seconds..."
  done
  echo -ne "\r" && printf " %.0s" {1..40} && echo -ne "\r"
}

#--------------------------------
print-banner-prefix() {
    printf "${GREEN}" && printf "=%.0s" {1..4} && printf "> ${ENDCOLOR}"
}

#--------------------------------
print-banner() {
  printf "\n"
  printf "${GREEN}" && printf "=%.0s" {1..20} && printf "${ENDCOLOR}"
  printf " $1 "
  printf "${GREEN}" && printf "=%.0s" {1..80} && printf "${ENDCOLOR}"
}

#--------------------------------
clone-eligible-files() {
  printf "\n${CYN}Cloning eligible files... ${ENDCOLOR}"
  
  setopt cshnullglob
  rm -rf ${tmpdir}
  mkdir -p ${tmpdir}

  for photo in *.jpg *.jpeg *.png *.webp; do
    [ -f "${photo}" ] || continue

    # measure panorama static image
    image_height=`gm identify -format '%h' ./${photo}`
    image_width=`gm identify -format '%w' ./${photo}`

    # only process images at least three times as wide as their height (panoramas)
    if [[ (${image_width} -gt 255) && (${image_width} -gt (3 * ${image_height})) ]]; then
      printf "${BLUE}${photo} (%s x %s)${ENDCOLOR}\t"  "$image_height" "$image_width"
      cp "${photo}" "${tmpdir}"/"${photo}"
      continue
    fi
  done

  printf "\n${CYN}Done!${ENDCOLOR}\n"
}

#--------------------------------
# WARNING: DESTRUCTIVE; work performed in temp subdirectory
canonicalize-file-types() {
  mkdir -p ${tmpdir}
  pushd ${tmpdir}
  printf "\n${CYN}Canonicalizing file-types... ${ENDCOLOR}"

  unsetopt nomatch
  setopt cshnullglob

  if test -n "$(find ./ -maxdepth 1 -name '*.webp' -print -quit)";
  then
    printf "\n${CYN} --> Converting .webp to .png... ${ENDCOLOR}"
    for photo in *.webp; do
      printf "${BLUE}${photo}${ENDCOLOR}\t"
      ffmpeg -y -i "${photo}" "${photo%.*}.png" && rm "${photo}"
    done
  fi

  if test -n "$(find ./ -maxdepth 1 -name '*.jpeg' -print -quit)";
  then
    printf "\n${CYN} --> Renaming .jpeg to .jpg ${ENDCOLOR}"
    for photo in *.jpeg; do
      [ -f "${photo}" ] || continue
      printf "${BLUE}${photo}/${photo%.*}.jpg${ENDCOLOR}\t"
      mv -f "${photo}" "${photo%.*}.jpg"
    done
  fi

  if test -n "$(find . -maxdepth 1 -name '*.jpg' -print -quit)"
  then
    printf "\n${CYN} --> Converting .jpg to .png ${ENDCOLOR}"
    for photo in *.jpg; do
      printf "${BLUE}${photo}${ENDCOLOR}\t"
      convertformat "${photo}" "${photo%.*}.png" && rm "${photo}"
    done
  fi

  printf "\n${CYN}Done!${ENDCOLOR}"
  popd
}

#--------------------------------
# WARNING: DESTRUCTIVE; work performed in temp subdirectory
transpose-images() {
  if [[ ${do_transpose_images} == "yes" ]]; then
    mkdir -p ${tmpdir}
    pushd ${tmpdir}
    printf "\n${CYN}Transposing files horizontally... ${ENDCOLOR}"

    for photo in *.png; do
      # optional horizontal flip
      [ -f "${photo}" ] || break
      printf "${BLUE}${photo}${ENDCOLOR}\t"
      sips -f horizontal "$photo"
    done

    printf "\n${CYN}Done!${ENDCOLOR}"
    popd
  fi
}

#--------------------------------
# WARNING: DESTRUCTIVE; work performed in temp subdirectory
canonicalize-file-names() {
  if [[ ${do_canonicalize_file_names} == "yes" ]]; then
    mkdir -p ${tmpdir}
    pushd ${tmpdir}
    printf "\n${CYN}Canonicalizing file-names... ${ENDCOLOR}"

    for photo in *.png; do
      [ -f "${photo}" ] || break
      printf "${BLUE}${photo}${ENDCOLOR}\t"
      sum=$(echo -n "${photo}"|/usr/local/Cellar/md5sha1sum/0.9.5_1/bin/md5sum);
      sum="${sum:2:12}"
      mv -f "${photo}" "${sum}.png"
    done

    printf "\n${CYN}Done!${ENDCOLOR}"
    popd
  fi
}

#--------------------------------
displayProgress() # Calculate/collect progress 
{
  FR_CNT=0;
  touch "./vstats"
  (( PERCENTAGE = 0 ))

######### There are so many better ways to do this, but zsh is acting up #########
#########  while [ -e /proc/$PID ]; do   # Is FFmpeg running? This would only work in a Linux system. Darwin doesn't have /proc support
#########  while [[ $( ps ${PID} ) ]]; do
#########  while ps -p ${PID} > /dev/null; do
#########  while $( `kill -0 ${PID} 2> /dev/null` ); do
#########  while [[ `lsof -p $PID +r 1m%s -t | grep -qm1 $(date -v+1S +%s 2>/dev/null || echo INF)` && true || false ]]; do

  while [[ ${PERCENTAGE} -lt 99 ]]; do

    sleep 2
    VSTATS=$(gawk '{gsub(/frame=/, "")}/./{line=$5} END{print line}' "./vstats")  # Parse vstats

    if [[ ${VSTATS} -gt ${FR_CNT} ]]; then
        FR_CNT=${VSTATS}
        (( PERCENTAGE = 100 * FR_CNT / TOT_FR ))
    fi

    echo -ne "\rCurrent frame: ${FR_CNT} of ${TOT_FR}     Elapsed time: $SECONDS seconds     Percent complete: ${PERCENTAGE}%"

  done

  sleep 10
  (( PERCENTAGE = 0 ))
  (( FR_CNT = 0 ))
  (( TOT_FR = 0 ))
  - rm -rf ./vstats ||:

  echo -ne "\r" && printf " %.0s" {1..120} && echo -ne "\r"
  sleep 2
}

#--------------------------------
doLongRunning_ffmpeg_Task() {
 
  touch vstats && - rm -rf vstats ||:
  touch vstats
  touch "${finalRender}" && - rm -rf "${finalRender}" ||:

  FPS=$(ffprobe "${intermediateRender}" 2>&1 | sed -n "s/.*, \(.*\) tbr.*/\1/p")
  DUR=$(ffprobe "${intermediateRender}" 2>&1 | sed -n "s/.* Duration: \([^,]*\), .*/\1/p")
  HRS=$(echo ${DUR} | cut -d":" -f1)
  MIN=$(echo ${DUR} | cut -d":" -f2)
  SEC=$(echo ${DUR} | cut -d":" -f3)
  TOT_FR=$(echo "(${HRS}*3600+${MIN}*60+${SEC})*${FPS}*${clock_multiplier}*${blurfactor}-${blurfactor}" | bc | cut -d"." -f1)

#  echo "\n\n### FPS: $FPS\tDUR: $DUR\tHRS: $HRS\tMIN: $MIN\tSEC: $SEC\tTOT_FR: $TOT_FR\n\n"

  if [[ ! "${TOT_FR}" -gt "0" ]]; then echo error; fi

  if [[ ${use_hw_accel} == "yes" ]]; then {
    nice -n 15 ffmpeg -y -vstats_file "$( pwd )/vstats" -i "${intermediateRender}" -vcodec h264_videotoolbox -vf \
                      "minterpolate='fps=${blurfactor}',setpts=${clock_multiplier}*PTS" -f mp4 "${finalRender}" 2>/dev/null &
  } else {
    nice -n 25 ffmpeg -y -vstats_file "$( pwd )/vstats" -i "${intermediateRender}" -vf \
                      "minterpolate='fps=${blurfactor}',setpts=${clock_multiplier}*PTS" -f mp4 "${finalRender}" 2>/dev/null &
  }
  fi

  PID=$! && 

#echo "\n\nPID: ${PID}"

  displayProgress
}

#--------------------------------
generate-smooth-mp4() {
  mkdir -p ${tmpdir}
  pushd ${tmpdir}
  printf "\n\n${CYN}Creating blended videos ${ENDCOLOR}"

  for photo in *.png; do
    # measure panorama static image
    image_height=`gm identify -format '%h' ./${photo}`
    image_width=`gm identify -format '%w' ./${photo}`

    # determine video width in accordance with Zoom's requirements (max 1920x1080)
    ((video_width = (image_height * 3) / 2))

    ((video_width = video_width > 1920 ? 1920 : video_width))
    ((video_width = video_width < 640 ? 640 : video_width))
    ((video_height = image_height > 1080 ? 1080 : image_height))

    # ffmpeg filters require even integers for alignment purposes
    ((video_width = (video_width / 2) ))
    ((video_width = (video_width * 2) ))
    ((video_height = (video_height / 2) ))
    ((video_height = (video_height * 2) ))

    ((pic_top_offset = image_height > 1080 ? image_height - 1080 : 0))
    ((num_video_frames = ($image_width - $video_width) * $pan_inc_denominator / ${pixel_slew} ))

    printf "\n"
    print-banner "Processing ${photo} (${image_width} x ${image_height})"
    printf "\n"
    print-banner-prefix && printf "${RED} Video dimensions: %s x %s; ${ENDCOLOR}${RED}%s frames${ENDCOLOR}\n" "${video_width}" "${video_height}" "${num_video_frames}"

    finalRender="${photo%.*}.mp4"
    if [[ -s ../"${finalRender}" ]]; then
      print-banner-prefix && printf "${RED} File found. Skipping. %s${ENDCOLOR}\n" "`du -h ../${finalRender}`"
    else
      print-banner-prefix && printf "${RED} Animating static png. Creating: ${BLUE}%s${ENDCOLOR}\n" "${finalRender}"

      (( SECONDS = 0 ))

      ffmpeg -loglevel ${log_level_ffmpeg} -hide_banner -y -loop 1 -r 1 -i "${photo}" \
              -vf "crop=${video_width}:${video_height}:${pixel_slew}*n/${pan_inc_denominator}:${pic_top_offset}" \
              -frames:v ${num_video_frames} -pix_fmt yuv420p -vcodec rawvideo -f nut "${intermediateRender}"

      doLongRunning_ffmpeg_Task

      - mv "${finalRender}" ../.
      - rm -rf "${intermediateRender}"

      print-banner-prefix && printf "${RED} Operation took $SECONDS seconds.${ENDCOLOR}\n"

      sleep-between-runs
    fi
  done

  printf "\n${CYN}Done!${ENDCOLOR}"
  popd
}

#--------------------------------
cleanup() {
  mv "${tmpdir}/*.mp4" .
  ls -alh *.mp4
  rm -rf "${tmpdir}"
}

#--------------------------------
# MAIN
#--------------------------------
printf "${GREEN}createPanoMovies.sh ${ENDCOLOR}\n"

clone-eligible-files
canonicalize-file-types
canonicalize-file-names
transpose-images
generate-smooth-mp4
cleanup

ls -alh ./*.mp4
printf "${GREEN}Done! ${ENDCOLOR}\n"
