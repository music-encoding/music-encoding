#!/bin/sh
echo "Create Guidelines PDF"
echo "====================="

html_path=`ls build/MEI_Guidelines*.html`
html_name=`basename -- $html_path`
basename="${html_name%.*}"
echo $html_path
echo $html_name
echo $basename
# just copied the command form our foregoing development meeeting, don't know if the trailing -v has to be there or why it is there
docker run --rm -it -v $(pwd):/out yeslogic/prince:14.2 /out/$(html_path).html -o /out/dist/guidelines/dev/$(basename).pdf --log /out/princeLog.txt -v
# alternatively use following line if you need to emulate thte plattform 
#docker run --platform=linux/amd64 --rm -it -v $(pwd):/out yeslogic/prince:14.2 /out/$html_path -o /out/dist/guidelines/dev/$basename.pdf --log /out/princeLog.txt -v
