#!/bin/bash
#----------------------------------------------------------------------------------
# This script runs Jonathan clark's bg2md.rb ruby script and formats the output
# to be useful in Obsidian. Find the script here: https://github.com/jgclark/BibleGateway-to-Markdown
#
# It needs to be run in the same directoy as the 'bg2md.rb' script and will output
# one .md file for each chapter, organising them in folders corresponding to the book.
# Navigation on the top and bottom is also added.
#
#----------------------------------------------------------------------------------
# SETTINGS
#----------------------------------------------------------------------------------
# Setting a different translation:
# Using the abbreviation with the -v flag, you can call on a different translation.
# It defaults to the "World English Bible", if you change the translation,
# make sure to honour the copyright restrictions.
#----------------------------------------------------------------------------------

show_help()
{
  echo "Usage: $0 [-beaih] [-v version]"
  echo "  -v version   Specify the translation to download (default = WEB)"
  echo "  -b    Set words of Jesus in bold"
  echo "  -e    Include editorial headers"
  echo "  -a    Create an alias in the YAML front matter for each chapter title"
  echo "  -i    Show download information (i.e. verbose mode)"
  echo "  -h    Display help"
  exit 1
}

# Extract command line options

# Clear translation variable if it exists and set defaults for others
ARG_TRANSLATION='WEB'    # Which translation to use
ARG_BOLD_WORDS="false"    # Set words of Jesus in bold
ARG_HEADERS="false"      # Include editorial headers
ARG_ALIASES="false"      # Create an alias in the YAML front matter for each chapter title
ARG_VERBOSE="false"      # Show download progress for each chapter

# Process command line args
while getopts 'v:beai?h' c
do
  case $c in
    v) ARG_TRANSLATION=$OPTARG ;;
    b) ARG_BOLD_WORDS="true" ;;
    e) ARG_HEADERS="true" ;;
    a) ARG_ALIASES="true" ;;
    i) ARG_VERBOSE="true" ;;
    h|?) show_help ;;
  esac
done

# Book list
declare -a book_array # Declaring the Books of the Bible as a list
declare -a abb_array # Delaring the abbreviations for each book. You can adapt if you'd like
declare -a chapter_array # Declaring amount of chapters in each book

# -------------------------------------------
# TRANSLATION: Lists of Names
# -------------------------------------------
# For Translation, translate these three lists. Seperated by space and wrapped in quotes if they include whitespace.

# Name of "The Bible" in your language
bible_name="The Bible"

# Full names of the books of the Bible
book_array=(Genesis Exodus Leviticus Numbers Deuteronomy Joshua Judges Ruth "1 Samuel" "2 Samuel" "1 Kings" "2 Kings" "1 Chronicles" "2 Chronicles" Ezra Nehemiah Esther Job Psalms Proverbs Ecclesiastes "Song of Solomon" Isaiah Jeremiah Lamentations Ezekiel Daniel Hosea Joel Amos Obadiah Jonah Micah Nahum Habakkuk Zephaniah Haggai Zechariah Malachi Matthew Mark Luke John Acts
Romans "1 Corinthians" "2 Corinthians" Galatians Ephesians Philippians Colossians "1 Thessalonians" "2 Thessalonians" "1 Timothy" "2 Timothy" Titus Philemon Hebrews James "1 Peter" "2 Peter" "1 John" "2 John" "3 John" Jude Revelation)

# Short names of the books of the Bible
abb_array=(Gen Exod Lev Num Deut Josh Judg Ruth "1 Sam" "2 Sam" "1 Kings" "2 Kings" "1 Chron" "2 Chron" Ezr Neh Esth Job Ps Prov Eccles Song Isa Jer Lam Ezek Dan Hos Joel Am Obad Jonah Micah Nah Hab Zeph Hag Zech Mal Matt Mark Luke John Acts Rom "1 Cor" "2 Cor" Gal Ephes Phil Col "1 Thess" "2 Thess" "1 Tim" "2 Tim" Titus Philem Heb James "1 Pet" "2 Pet" "1 John" "2 John" "3 John" Jude Rev)

# Book chapter list
chapter_array=(50 40 27 36 34 24 21 4 31 24 22 25 29 36 10 13 10 42 150 31 12 8 66 52 5 48 12 14 3 9 1 4 7 3 3 3 2 14 4 28 16 24 21 28 16 16 13 6 6 4 4 5 3 6 4 3 1 13 5 5 3 5 1 1 1 22)
# -------------------------------------------

# Initialise the name of the Bible folder
bible_folder="$bible_name ($ARG_TRANSLATION)"

# Initialise the "The Bible" file for all of the books
echo -e "# $bible_name\n" > "$bible_name.md"

if ${ARG_VERBOSE} -eq "true"; then
  echo -n "Starting download of $ARG_TRANSLATION Bible."
fi

# Loop through the books of the Bible
for ((book_index=0; book_index<66; book_index++))
do

  if $ARG_VERBOSE -eq "true"; then
    # Create a new line for verbose output
    echo ""
  fi

  book=${book_array[$book_index]}
  last_chapter=${chapter_array[$book_index]}
  abbreviation=${abb_array[$book_index]}

  if $ARG_VERBOSE -eq "true"; then
    echo -n "$book "
  fi

  # Loop through each chapter of this book
  for ((chapter=1; chapter<=last_chapter; chapter++))
  do
    if $ARG_VERBOSE -eq "true"; then
      echo -n "."
    fi

    # Counting the previous and next chapter for navigation
    ((prev_chapter=chapter-1))
    ((next_chapter=chapter+1))

    # File naming
    this_file="$abbreviation $chapter"
    prev_file="$abbreviation $prev_chapter"
    next_file="$abbreviation $next_chapter"

    # Formatting Navigation and omitting links that aren't necessary
    navigation="[[$book]]"
    if [ $chapter -gt 1 ]; then
      navigation="[[$prev_file|← $book $prev_chapter]] | $navigation"
    fi
    if [ $chapter -lt $last_chapter ]; then
      navigation="$navigation | [[$next_file|$book $next_chapter →]]"
    fi

    # Set the appropriate flags for the 'bg2md_mod' script
    bg2md_flags="-c -f -l -r"
    if $ARG_BOLD_WORDS -eq "true"; then
      bg2md_flags="${bg2md_flags} -b"
    fi
    if $ARG_HEADERS -eq "false"; then
      bg2md_flags="${bg2md_flags} -e"
    fi

    # Call the 'bg2md_mod' script
    content=$(ruby bg2md.rb $bg2md_flags -v $ARG_TRANSLATION $book $chapter)

    # Delete unwanted headers
    content=$(echo $content | sed 's/^(.*?)v1/v1/')

    # Format the title for markdown
    title="# $book $chapter"

    # Navigation format
    export="$title\n\n$navigation\n***\n\n$content\n\n***\n$navigation"
    if $ARG_ALIASES -eq "true"; then
      # Add other aliases or 'Tags:' here if desired. Make sure to follow proper YAML format.
      alias="---\nAliases: [$book $chapter]\n---\n"
      export="$alias$export"
    fi

    # Create a new file for this chapter
    echo -e $export > "$this_file.md"

    # Create a folder for this book of the Bible if it doesn't exist, then move the new file into it
    mkdir -p "./$bible_folder/$book"; mv "$this_file".md "./$bible_folder/$book"

  done # End of chapter loop

  # Create an overview file for each book of the Bible:
  overview_file="links: [[$bible_name]]\n# $book\n\n[[$abbreviation 1|Start Reading →]]"
  echo -e $overview_file > "$book.md"
  mv "$book.md" "./$bible_folder/$book"

  # Append the bookname to the main Bible index file
  echo -e "* [[$book]]" >> "$bible_name.md"

done # End of book loop

# Tidy up the Markdown files by removing unneeded headers and separating the verses
# with some blank space and an H6-level verse number.

# Using a perl one-liner here in order to help ensure that this works across platforms
# since the sed utility works differently on macOS and Linux variants. The perl should
# work consistently.

if $ARG_VERBOSE -eq "true"; then
  echo ""
  echo "Cleaning up the Markdown files."
fi

# Clear unnecessary headers
find . -name "*.md" -print0 | xargs -0 perl -pi -e 's/#.*(#####\D[1]\D)/#$1/g'

# Format verses into H6 headers
find . -name "*.md" -print0 | xargs -0 perl -pi -e 's/######\s([0-9]\s|[0-9][0-9]\s|[0-9][0-9][0-9]\s)/\n\n###### $1\n/g'

# Delete crossreferences
find . -name "*.md" -print0 | xargs -0 perl -pi -e 's/\<crossref intro.*crossref\>//g'

if $ARG_VERBOSE -eq "true"; then
  echo "Download complete. Markdown files ready for Obsidian import."
fi
