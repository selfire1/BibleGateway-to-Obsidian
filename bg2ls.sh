#!/bin/bash
#----------------------------------------------------------------------------------
# This script runs Jonathan clark's bg2md.rb ruby script and formats the output
# to be useful in Logseq. Find the script here: https://github.com/jgclark/BibleGateway-to-Markdown
#
# It needs to be run in the same directory as the 'bg2md.rb' script and will output
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

usage()
{
	echo "Usage: $0 [-beaicyh] [-v version]"
	echo "  -v version   Specify the translation to download (default = WEB)"
	echo "  -b    Set words of Jesus in bold"
	echo "  -e    Include editorial headers"
	echo "  -a    Create an alias in for each chapter title"
	echo "  -i    Show download information (i.e. verbose mode)"
	echo "  -c    Include inline navigation for the breadcrumbs plugin (e.g. 'up', 'next','previous')"
	echo "  -y    Print navigation for the breadcrumbs plugin (e.g. 'up', 'next','previous') in the frontmatter (YAML)"
	echo "  -h    Display help"
	exit 1
}

# Extract command line options

# Clear translation variable if it exists and set defaults for others
translation='WEB'    # Which translation to use
boldwords="false"    # Set words of Jesus in bold
headers="false"      # Include editorial headers
aliases="false"      # Create an alias for each chapter title
verbose="false"      # Show download progress for each chapter
breadcrumbs_inline="false"      # Print breadcrumbs in the file
breadcrumbs_yaml="false"      # Print breadcrumbs in the YAML

# Process command line args
while getopts 'v:beaicy?h' c
do
	case $c in
		v) translation=$OPTARG ;;
		b) boldwords="true" ;;
		e) headers="true" ;;
		a) aliases="true" ;;
		i) verbose="true" ;;
		c) breadcrumbs_inline="true" ;;
		y) breadcrumbs_yaml="true" ;;
		h|?) usage ;; 
	esac
done

# Copyright disclaimer
echo "I confirm that I have checked and understand the copyright/license conditions for ${translation} and wish to continue downloading it in its entirety.?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

# Initialize variables
book_counter=0 # Setting the counter to 0
book_counter_max=66 # Setting the max amount to 66, since there are 66 books we want to import

# Book list
declare -a bookarray # Declaring the Books of the Bible as a list
declare -a abbarray # Delaring the abbreviations for each book. You can adapt if you'd like
declare -a lengtharray # Declaring amount of chapters in each book

# -------------------------------------------
# TRANSLATION: Lists of Names
# -------------------------------------------
# For Translation, translate these three lists. Seperated by space and wrapped in quotes if they include whitespace.
# Name of "The Bible" in your language
biblename="The Bible"
# Full names of the books of the Bible
bookarray=(Genesis Exodus Leviticus Numbers Deuteronomy Joshua Judges Ruth "1 Samuel" "2 Samuel" "1 Kings" "2 Kings" "1 Chronicles" "2 Chronicles" Ezra Nehemiah Esther Job Psalms Proverbs Ecclesiastes "Song of Solomon" Isaiah Jeremiah Lamentations Ezekiel Daniel Hosea Joel Amos Obadiah Jonah Micah Nahum Habakkuk Zephaniah Haggai Zechariah Malachi Matthew Mark Luke John Acts
Romans "1 Corinthians" "2 Corinthians" Galatians Ephesians Philippians Colossians "1 Thessalonians" "2 Thessalonians" "1 Timothy" "2 Timothy" Titus Philemon Hebrews James "1 Peter" "2 Peter" "1 John" "2 John" "3 John" Jude Revelation)
# Short names of the books of the Bible
abbarray=(Gen Exod Lev Num Deut Josh Judg Ruth "1 Sam" "2 Sam" "1 Kings" "2 Kings" "1 Chron" "2 Chron" Ezr Neh Esth Job Ps Prov Eccles Song Isa Jer Lam Ezek Dan Hos Joel Am Obad Jonah Micah Nah Hab Zeph Hag Zech Mal Matt Mark Luke John Acts Rom "1 Cor" "2 Cor" Gal Ephes Phil Col "1 Thess" "2 Thess" "1 Tim" "2 Tim" Titus Philem Heb James "1 Pet" "2 Pet" "1 John" "2 John" "3 John" Jude Rev)
# -------------------------------------------

# Book chapter list
lengtharray=(50 40 27 36 34 24 21 4 31 24 22 25 29 36 10 13 10 42 150 31 12 8 66 52 5 48 12 14 3 9 1 4 7 3 3 3 2 14 4 28 16 24 21 28 16 16 13 6 6 4 4 5 3 6 4 3 1 13 5 5 3 5 1 1 1 22)

# Initialise the "The Bible" file for all of the books
echo -e "# ${biblename}\n" >> "${biblename}.md"

if [[ $verbose = "true" ]] ; then
	echo "Starting download of ${translation} Bible."
fi

 # Cycling through the book counter, setting which book and its maxchapter
  for ((book_counter=0; book_counter <= book_counter_max; book_counter++))
  do

	if [[ $verbose = "true" ]] ; then
		echo ""   # Make a new line which the '-n' flag to the echo command prevents.
	fi

    book=${bookarray[$book_counter]}
    maxchapter=${lengtharray[$book_counter]}
    abbreviation=${abbarray[$book_counter]}

	if [[ $verbose = "true" ]] ; then
		echo -n "${book} "
	fi

    for ((chapter=1; chapter <= maxchapter; chapter++))
    do

    	if [[ $verbose = "true" ]] ; then
    		echo -n "."
		fi

((prev_chapter=chapter-1)) # Counting the previous and next chapter for navigation
((next_chapter=chapter+1))

# Exporting
export_prefix="${abbreviation} " # Setting the first half of the filename
filename=${export_prefix}$chapter # Setting the filename


  prev_file=${export_prefix}$prev_chapter # Naming previous and next files
  next_file=${export_prefix}$next_chapter

  # Navigation with INLINE BREADCRUMBS DISABLED and YAML DISABLED – write normal navigation
  if [[ $breadcrumbs_inline = "false" && $breadcrumbs_yaml = "false" ]]; then

  # Formatting Navigation and omitting links that aren't necessary
  if [[ $maxchapter = 1 ]]; then
    # For a book that only has one chapter
    navigation="[[${book}]]"
  elif [[ $chapter = $maxchapter ]]; then
    # If this is the last chapter of the book
    navigation="[← ${book} ${prev_chapter}]([[${prev_file}]]) | [[${book}]]"
  elif [[ ${chapter} = 1 ]] ; then
    # If this is the first chapter of the book
    navigation="[[${book}]] | [${book} ${next_chapter} →]([[${next_file}]])"
  else
    # Navigation for everything else
    navigation="[← ${book} ${prev_chapter}]([[${prev_file}]]) | [[${book}]] | [${book} ${next_chapter} →]([[${next_file}]])"
  fi
  fi

  # Navigation with INLINE BREADCRUMBS ENABLED
  if [[ $breadcrumbs_inline = "true" ]] ; then
  # Formatting Navigation and omitting links that aren't necessary
  if [[ ${maxchapter} = 1 ]] ; then
    # For a book that only has one chapter
    navigation="(up:: [[${book}]])"
  elif [[ $chapter = $maxchapter ]] ; then
    # If this is the last chapter of the book
    navigation="(previous:: [[${prev_file}|← ${book} ${prev_chapter}]]) | (up:: [[${book}]])"
  elif [[ $chapter = 1 ]] ; then
    # If this is the first chapter of the book
    navigation="(up:: [[${book}]]) | (next:: [[${next_file}|${book} ${next_chapter} →]])"
  else
    # Navigation for everything else
    navigation="(previous:: [[${prev_file}|← ${book} ${prev_chapter}]]) | (up:: [[${book}]]) | (next:: [[${next_file}|${book} ${next_chapter} →]])"
  fi
  fi

  if [[ $boldwords = "true" && $headers = "false" ]] ; then
    text=$(ruby bg2md.rb -e -c -b -f -l -r -v "${translation}" "${book} ${chapter}") # This calls the 'bg2md_mod' script
  elif [[ $boldwords = "true" && $headers = "true" ]] ; then
    text=$(ruby bg2md.rb -c -b -f -l -r -v "${translation}" "${book} ${chapter}") # This calls the 'bg2md_mod' script
  elif [[ $boldwords = "false" && $headers = "true" ]] ; then
    text=$(ruby bg2md.rb -e -c -f -l -r -v "${translation}" "${book} ${chapter}") # This calls the 'bg2md_mod' script
  else
    text=$(ruby bg2md.rb -e -c -f -l -r -v "${translation}" "${book} ${chapter}") # This calls the 'bg2md_mod' script
  fi


  text=$(echo "$text" | sed 's/^(.*?)v1/v1/') # Deleting unwanted headers

  # Formatting the title for markdown
  title="# ${book} ${chapter}"

  # Navigation format
  if [[ $breadcrumbs_yaml = "true" ]]; then
  export="${title}\n***\n\n$text"
  else
  export="${title}\n\n$navigation\n\n$text\n\n***\n$navigation"
  fi

# YAML
yaml_start=""
yaml_end=""
alias="Aliases:: [${book} ${chapter}]" # Add other aliases or 'Tags:' here if desired. Make sure to follow proper YAML format.

  # Navigation with INLINE BREADCRUMBS ENABLED
  if [[ $breadcrumbs_yaml = "true" ]] ; then
  # Formatting Navigation and omitting links that aren't necessary
  if [[ $maxchapter = 1 ]] ; then
    # For a book that only has one chapter
    bc_yaml="up: ['${book}']"
  elif [[ $chapter = $maxchapter ]] ; then
    # If this is the last chapter of the book
    bc_yaml="previous: ['${prev_file}']\nup: ['${book}']"
  elif [[ $chapter = 1 ]] ; then
    # If this is the first chapter of the book
    bc_yaml="up: ['${book}']\nnext: ['${next_file}']"
  else
    # Navigation for everything else
    bc_yaml="up: ['${book}']\nprevious: ['${prev_file}']\nnext: ['${next_file}']"
  fi
  fi

# Printing YAML
  if [ ${aliases} == "true" ] && [ ${breadcrumbs_yaml} == "false" ]; then
    yaml="${alias}"
  elif [ ${aliases} == "true" ] && [ ${breadcrumbs_yaml} == "true" ]; then
    yaml="${yaml_start}${alias}\n${bc_yaml}${yaml_end}"
    elif [ ${aliases} == "false" ] && [ ${breadcrumbs_yaml} == "true" ]; then
    yaml="${yaml_start}${bc_yaml}${yaml_end}"
  fi
  

  export="${yaml}${export}"
  # Export
  echo -e "$export" >> "$filename.md"

  # Creating a folder

  folder_name="${book}" # Setting the folder name

  # Creating a folder for the book of the Bible if it doesn't exist, otherwise moving new file into existing folder
  mkdir -p "./${biblename} (${translation})"; mv "${filename}".md "./${biblename} (${translation})"


done # End of the book exporting loop

  # Create an overview file for each book of the Bible:
  overview_file="links: [[${biblename}]]\n# ${book}\n\n[Start Reading →]([[${abbreviation} 1]])"
  echo -e $overview_file >> "$book.md"
  mv "$book.md" "./${biblename} (${translation})/${folder_name}"

  # Append the bookname to "The Bible" file
  echo -e "* [[${book}]]" >> "${biblename}.md"
  done

# Tidy up the Markdown files by removing unneeded headers and separating the verses
# with some blank space and an H6-level verse number.
#
# Using a perl one-liner here in order to help ensure that this works across platforms
# since the sed utility works differently on macOS and Linux variants. The perl should
# work consistently.

if [[ $verbose = "true" ]] ; then
	echo ""
	echo "Cleaning up the Markdown files."
fi
# Clear unnecessary headers
find . -name "*.md" -print0 | xargs -0 perl -pi -e 's/#.*(#####\D[1]\D)/#$1/g'

# Format verses into H6 headers
find . -name "*.md" -print0 | xargs -0 perl -pi -e 's/######\s([0-9]\s|[0-9][0-9]\s|[0-9][0-9][0-9]\s)/\n\n###### $1\n/g'

# Delete crossreferences
find . -name "*.md" -print0 | xargs -0 perl -pi -e 's/\<crossref intro.*crossref\>//g'

if [[ $verbose = "true" ]]; then
echo "Download complete. Markdown files ready for Logseq import."
fi
