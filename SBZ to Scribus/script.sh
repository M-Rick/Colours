#! /bin/sh

# SwatchBook SBZ to Scribus XML colors
# Aymeric GILLAIZEAU

for f in "$@"
do

  NAME=$(basename -- "$f") ; NAME="${NAME%.*}" ; NAME=$( echo "$NAME" | sed 's/_/ /g');

  tar -xf "$f"

  f="swatchbook.xml"

  if grep -q "<dc\:title>" "$f" ; then
    TITLE=$(echo "$a" | \
    cat "$f" | sed -e 's/^[ \t]*//' | \
    awk '/title>/,/title>/' | \
    sed 's|<dc:title>||' | \
    sed 's|<\/dc:title>||')
  else
    TITLE="$NAME"
  fi

  if grep -q "<dc\:license>" "$f" ; then
    LICENSE=$(echo "$a" | \
    cat "$f" | sed -e 's/^[ \t]*//' | \
    awk '/license>/,/license>/' | \
    sed 's|<dc:license>||' | \
    sed 's|<\/dc:license>||')
  else
    LICENSE=""
  fi

  echo '<?xml version="1.0" encoding="UTF-8"?>
  <!-- '${LICENSE}' -->
  <SCRIBUSCOLORS NAME="'${TITLE}'">' > "$HOME"/header.txt

  if grep -q 'Lab' "$f" ; then

    # LAB values
    cat "$f" | sed -e 's/^[ \t]*//' | \
    awk '/<values/,/values>/' | \
    sed 's/[^0-9. ]//g' | \
    sed 's/ //' | \
    sed 's/ /" B="/2' | \
    sed 's/ /" A="/1' | \
    sed 's|^|SPACE="Lab" L="|' | \
    if grep -q 'spot' "$f" ; then
      sed 's|$|" Spot="1"/>|' > "$HOME"/values.txt
    else
      sed 's|$|" Spot="0"/>|' > "$HOME"/values.txt
    fi

  elif grep -q 'RGB' "$f" ; then

    # RGB values

    if grep -q 'model="RGB">#' "$f" || grep -q 'model="sRGB">#' "$f" ; then
      cat "$f" | sed -e 's/^[ \t]*//' | \
      awk '/<values/,/values>/' | \
      sed 's|<values model="RGB">||' | \
      sed 's|<values model="sRGB">||' | \
      sed 's|</values>||' | \
      sed 's/[^0-9#abcdefABCDEF ]//g' | \
      sed 's/ //' | \
      if grep -q 'model="sRGB">' "$f" ; then
        sed 's|^|sRGB="|'
      else
        sed 's|^|RGB="|'
      fi | \
      if grep -q 'spot' "$f" ; then
        sed 's|$|" Spot="1"/>|' > "$HOME"/values.txt
      else
        sed 's|$|" Spot="0"/>|' > "$HOME"/values.txt
      fi
    else
      cat "$f" | sed -e 's/^[ \t]*//' | \
      awk '/<values/,/values>/' | \
      sed 's/[^0-9. ]//g' | \
      sed 's/ //' | \
      sed 's/ /" B="/2' | \
      sed 's/ /" G="/1' | \
      if grep -q 'model="sRGB">' "$f" ; then
        sed 's|^|SPACE="sRGB" R="|'
      else
        sed 's|^|SPACE="RGB" R="|'
      fi | \
      if grep -q 'spot' "$f" ; then
        sed 's|$|" Spot="1"/>|' > "$HOME"/values.txt
      else
        sed 's|$|" Spot="0"/>|' > "$HOME"/values.txt
      fi
    fi

  elif grep -q 'CMYK' "$f" ; then

    # CMYK values
    cat "$f" | sed -e 's/^[ \t]*//' | \
    awk '/<values/,/values>/' | \
    sed 's/[^0-9. ]//g' | \
    sed 's/ //' | \
    sed 's/ /" K="/3' | \
    sed 's/ /" Y="/2' | \
    sed 's/ /" M="/1' | \
    sed 's|^|SPACE="CMYK" C="|' | \
    if grep -q 'spot' "$f" ; then
      sed 's|$|" Spot="1"/>|' > "$HOME"/values.txt
    else
      sed 's|$|" Spot="0"/>|' > "$HOME"/values.txt
    fi

  fi

  # Keep names
  cat "$f" | sed -e 's/^[ \t]*//' | \
  awk '/identifier>/,/identifier>/' | \
  sed 's/<dc:identifier>//' | \
  sed 's/<\/dc:identifier>//' | \
  sed 's/\t*//' | \
  sed 's|^|<COLOR NAME="|' | \
  sed 's|$|"|' > "$HOME"/names.txt

  paste names.txt values.txt | sed 's/\t/ /' | sed '/^<COLOR/ s/./\t\t&/' > "$HOME"/colors.txt

  cat "$HOME"/header.txt "$HOME"/colors.txt | sed '$a\
  <\/SCRIBUSCOLORS>' > "$HOME"/Desktop/"$TITLE".xml

  rm -f colors.txt header.txt names.txt values.txt swatchbook.xml

done
