#! /bin/sh

# SwatchBook SBZ CIE Lab to Scribus CIE Lab spot colors
# Aymeric GILLAIZEAU

for f in "$@"
do

NAME=$(basename -- "$f") ; NAME="${NAME%.*}" ; NAME=$( echo "$NAME" | sed 's/_/ /g'); \
exec cat "$f" | sed -e 's/^[ \t]*//' | \
sed 's#<materials>#<SCRIBUSCOLORS>#' | \
sed 's#</materials>#</SCRIBUSCOLORS>#' | \
sed 's#<dc:identifier>\(.*\)#<COLOR NAME="\1" #' | \
sed 's#</values># Spot="1" />#' | \
sed '/<metadata>/d' | \
sed 's#</metadata>#<@metadata>#' | \
sed '/<@metadata>/d' | \
sed 's#</dc:identifier>##' | \
sed 's#</color>#<@color>#' | \
sed '/<@color>/d' | \
sed '/<SwatchBook/d' | \
sed '/xmlns/d' | \
sed '/<dc:format/d' | \
sed '/<dc:type/d' | \
sed '/<book>/d' | \
sed 's#</book>#<@book>#' | \
sed '/<@book>/d' | \
sed 's#</SwatchBook>#<@SwatchBook>#' | \
sed '/<@SwatchBook>/d' | \
sed '/<swatch material=/d' | \
sed '/<color usage="spot">/d' | \
sed 's#<dc:rights>##' | \
sed 's#</dc:rights>##' | \
sed 's#<dc:license>##' | \
sed 's#</dc:license>##' | \
sed 's# *<dc:title>#<SCRIBUSCOLORS Name="#' | \
sed 's#</dc:title>#" >#' | \
sed 's#<dcterms:\(.*\)/>#<!-- \1-->#' | \
sed 's#<dc:description>#<!--\
#' | sed 's#<dc:description #<!-- #' | \
sed 's#</dc:description>#\
-->#' | sed 's#<values model="Lab">#<VALUES>=#' | \
sed -E 's/(=)([[:digit:].-]+) ([[:digit:].-]+) ([[:digit:].-]+)/ L\1"\2" A\1"\3" B\1"\4"/' | \
sed 's#<VALUES>#SPACE="Lab"#' | \
awk '/<COLOR NAME=".*" $/ { printf("%s", $0); next } 1' | \
sed "/<COLOR/ s/.*/${a}   &/" > "$HOME"/Desktop/"$NAME".xml

done
