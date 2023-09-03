# Aside from the addition of the "function" keyword, I don't remember the
# last time I looked at these nor used them. They originated from a time when
# I tried to go suckless and it turned out that designing your own desktop
# environment is not very productive. These are left for historic reasons.

sensitivity() {
  USAGE="usage: sensitivity [SCALE=1.3] [DEVICE=\$__OPSEC_PRIMARY_MOUSE]"
  SCALE=$1 && [ -z "${SCALE:=1.3}" ] \
    && echo >&2 "$USAGE" \
    && return 1
  DEVICE=$2 && [ -z "${DEVICE:=$__OPSEC_PRIMARY_MOUSE}" ] \
    && echo >&2 "$USAGE" \
    && return 1
  xinput set-prop "$DEVICE" "Coordinate Transformation Matrix" \
    $SCALE    0.0   0.0 \
       0.0 $SCALE   0.0 \
       0.0    0.0   1.0 \
    && echo "OK" \
    || echo >&2 "FAIL"
}

audio-concat() {
  OUTFILE=${1:?"audioconcat OUTPUT INPUT..."}
  OUTLIST="$OUT.audioconcat-tmp.in"
  shift

  for file in "$@"; do 
    echo "file '$file'\n"
  done > "$OUTLIST"

  ffmpeg -f concat \
     -safe 0 \
     -i "$OUTLIST" \
     -c copy \
     "$OUTFILE"

  rm "$OUTLIST"
}

pdf-diff() {
  # This very crudly uses ImageMagick to detect pixel differences between pages 
  # of two PDF files and overlay the difference on the new file by using a 
  # ridiculously small DPI to make the "smudges" easier to spot when blazing 
  # past the pages in a pdf viewer.
  OUTPUT=${1:-"pdfdiff OUTPUT OLD NEW"}
  PDF_OLD=${2:-"pdfdiff OUTPUT OLD NEW"}
  PDF_NEW=${3:-"pdfdiff OUTPUT OLD NEW"}

  DIR_WORK=$(mktemp -d /tmp/pdfdiff.XXXXXX)
  DIR_OLD="$DIR_WORK/old"
  DIR_NEW="$DIR_WORK/new"
  DIR_DIFF="$DIR_WORK/diff"

  mkdir -p "$DIR_OLD" "$DIR_NEW" "$DIR_DIFF"

  pdftk "$PDF_OLD" burst output "$DIR_OLD/%05d.pdf"
  pdftk "$PDF_NEW" burst output "$DIR_NEW/%05d.pdf"

  for OLD_PAGE in "$DIR_OLD"/*.pdf; do
  echo "Processing $OLD_PAGE"

  BASE_NAME=$(basename "$OLD_PAGE")
  NEW_PAGE="$DIR_NEW/$BASE_NAME"
  DIFF_IMAGE="$DIR_DIFF/$BASE_NAME.png"
  DIFF_PAGE="$DIR_DIFF/$BASE_NAME"

  compare -density 10 \
    -lowlight-color '#00000000' \
    -highlight-color '#ff00007f' \
    "$OLD_PAGE" \
    "$NEW_PAGE" \
    -compose src \
    "$DIFF_IMAGE"

  convert -density 120 \
    "$NEW_PAGE" \
    "$DIFF_IMAGE" \
    -set option:distort:viewport "%[fx:u.w]x%[fx:u.h]" \
    -distort "SRT" "0, 0, %[fx:u.w/s.w], %[fx:u.h/s.h], 0" \
    -compose srcover \
    -composite \
    "$DIFF_PAGE"
  done

  pdftk "$DIR_DIFF/"*.pdf cat output "$OUTPUT"
}

pdf-merge() {
  # This is mostly a historic relic at this point. I have been using pdftk for 
  # a while now which is significantly more productive that this garbage. You 
  # can tell I wrote this a long time ago by the fact that I didn't know about 
  # the ${:?} variable expansion.
  if [ -z $1 -o -z $2 ]; then
    echo "usage: pdfmerge OUTPUT INPUT..."
    return 1
  fi
  OUT=$1
  if [ -e $OUT ]; then
    echo "Output file already exists: aborting."
    return 2
  fi
  shift
  /usr/bin/gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile="$OUT" $@
}

tex-docm() {
  # I believe the reason I wrote this was because the original texdoc didn't 
  # open the PDF documentation files for whatever reason. This was a pretty
  # simple solution.
  if [ -z $1 ]; then
    echo >&2 "usage: texdocm PACKAGE"
    return 1
  fi
  PACKAGE="$1"
  DOCFILE=$(find "/usr/local/share/texmf/doc/" -name "${PACKAGE}.pdf" | head -n 1)
  if [ -z $DOCFILE ]; then
    echo >&2 "texdocm: ${PACKAGE}.pdf not found"
    return 2
  fi
  pdf $DOCFILE
}

# vi: sw=2 sts=2 ts=2 et cc=80 ft=zsh
