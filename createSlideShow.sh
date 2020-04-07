#!/bin/zsh
setopt cshnullglob nullglob

# terminal colors
RED=$'\e[1;31m'
GREEN=$'\e[1;32m'
YELLOW=$'\e[1;33m'
BLUE=$'\e[1;34m'
MAG=$'\e[1;35m'
CYN=$'\e[1;36m'
ENDCOLOR=$'\e[0m'

tmpdir="createSlideShow_tmp"

do_canonicalize_file_names="yes"
do_transpose_images="no"

log_level_ffmpeg="quiet"

# time stretch constant
clock_multiplier=30.0

#--------------------------------
clone-eligible-files() {
  printf "\n${CYN}cloning eligible files... ${ENDCOLOR}"

  rm -rf ${tmpdir}
  mkdir -p ${tmpdir}

  for photo in *.jpg *.jpeg *.png *.webp; do
    if [[ -e "${photo}" ]]; then
      printf "${BLUE}${photo}${ENDCOLOR}\t"
      cp "${photo}" "${tmpdir}"/"${photo}"
    fi 
  done

  printf "\n${CYN}cloning eligible files... Done!${ENDCOLOR}\n"
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
    printf "\n\t${CYN}\tConverting .webp to .png... ${ENDCOLOR}"
    for photo in *.webp; do
      printf "${BLUE}${photo}${ENDCOLOR}\t"
      ffmpeg -y -i "${photo}" "${photo%.*}.png" && rm "${photo}"
    done
  fi

  if test -n "$(find ./ -maxdepth 1 -name '*.jpeg' -print -quit)";
  then
    printf "\n\t${CYN}\tRenaming .jpeg to .jpg ${ENDCOLOR}"
    for photo in *.jpeg; do
      [ -f "${photo}" ] || continue
      printf "${BLUE}${photo}${ENDCOLOR}\t"
      mv -f "${photo}" "${photo%.*}.jpg"
    done
  fi

  if test -n "$(find . -maxdepth 1 -name '*.jpg' -print -quit)"
  then
    printf "\n\t${CYN}\tConverting .jpg to .png ${ENDCOLOR}"
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
      sips -f horizontal "${photo}"
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
generate-mp4() {
  mkdir -p ${tmpdir}
  pushd ${tmpdir}
  printf "\n${CYN}Generating video... ${ENDCOLOR}"

  output="slideshow.mp4"
  if [[ -s ../"${output}" ]]; then
    printf "${RED} File found. Skipping. %s${ENDCOLOR}\n" "`du -h ../${output}`"
  else
    rm -rf ./files.txt
    for photo in *.png; do
      printf "file ${photo}\n" >> files.txt
    done

    cat files.txt

    ffmpeg -loglevel ${log_level_ffmpeg} -hide_banner -y -f concat -r 1 -i files.txt -r 1 \
          -pix_fmt yuv420p -vcodec rawvideo -f nut -filter_complex "[0:v]setpts=1.5*PTS,scale=1920:1080:force_original_aspect_ratio=decrease,\
          pad=1920:1080:(ow-iw)/2:(oh-ih)/2:white,setsar=1/1,setdar=16/9[v]" -map "[v]" - | \
    ffmpeg -loglevel ${log_level_ffmpeg} -hide_banner -y -i - -filter:v "setpts=${clock_multiplier}*PTS" -c:a copy -vsync vfr ${output}

    mv ${output} ..
  fi

  printf "\n${CYN}Done!${ENDCOLOR}"
  popd
}

#--------------------------------
cleanup() {
  mv "${tmpdir}/slideshow.mp4" .
  rm -rf "${tmpdir}"
}

#--------------------------------
# MAIN
#--------------------------------
printf "${GREEN}createSlideshow.sh ${ENDCOLOR}\n"

clone-eligible-files
canonicalize-file-types
canonicalize-file-names
transpose-images
generate-mp4
cleanup

ls -alh ./*.mp4
printf "${GREEN}Done! ${ENDCOLOR}\n"
