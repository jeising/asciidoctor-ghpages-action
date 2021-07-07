#!/bin/bash

# Exit if a command fails
set -e

sh -c "echo 'Input Parameters:' $*"

OWNER="$(echo $GITHUB_REPOSITORY| cut -d'/' -f 1)"

if [[ "$INPUT_ADOC_FILE_EXT" != .* ]]; then 
    INPUT_ADOC_FILE_EXT=".$INPUT_ADOC_FILE_EXT"; 

if [[ $INPUT_SLIDES_SKIP_ASCIIDOCTOR_BUILD == false ]]; then 
    echo "Converting AsciiDoc files to HTML"
    find . -name "*$INPUT_ADOC_FILE_EXT" | xargs asciidoctor -b html $INPUT_ASCIIDOCTOR_PARAMS

    for FILE in `find . -name "README.html"`; do 
        ln -s "$FILE" "`dirname $FILE`/index.html"; 
    done

    for FILE in `find . -name "*.html"`; do 
        git add -f "$FILE"; 
    done

    find . -name "*$INPUT_ADOC_FILE_EXT" | xargs git rm -f --cached
fi

if [[ $INPUT_PDF_BUILD == true ]]; then 
    PDF_FILE="ebook.pdf"
    INPUT_EBOOK_MAIN_ADOC_FILE="$INPUT_EBOOK_MAIN_ADOC_FILE$INPUT_ADOC_FILE_EXT"
    MSG="Building $PDF_FILE ebook from $INPUT_EBOOK_MAIN_ADOC_FILE"
    echo $MSG
    asciidoctor-pdf "$INPUT_EBOOK_MAIN_ADOC_FILE" -o "$PDF_FILE" $INPUT_ASCIIDOCTOR_PARAMS
    git add -f "$PDF_FILE"; 
fi

if [[ $INPUT_SLIDES_BUILD == true ]]; then 
    echo "Build AsciiDoc Reveal.js slides"
    SLIDES_FILE="slides.html"
    INPUT_SLIDES_MAIN_ADOC_FILE="$INPUT_SLIDES_MAIN_ADOC_FILE$INPUT_ADOC_FILE_EXT"
    MSG="Building $SLIDES_FILE with AsciiDoc Reveal.js from $INPUT_SLIDES_MAIN_ADOC_FILE"
    echo $MSG
    asciidoctor-revealjs -a revealjsdir=https://cdnjs.cloudflare.com/ajax/libs/reveal.js/3.9.2 "$INPUT_SLIDES_MAIN_ADOC_FILE" -o "$SLIDES_FILE" 
    git add -f "$SLIDES_FILE"; 
fi
