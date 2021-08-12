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

usage()
{
	echo "Usage: $0 [-beaih] [-v version]"
	echo "  -v version   Specify the translation to download (default = NABRE)"
	echo "  -b    Set words of Jesus in bold"
	echo "  -e    Include editorial headers"
	echo "  -a    Create an alias in the YAML front matter for each chapter title"
	echo "  -i    Show download information (i.e. verbose mode)"
	echo "  -h    Display help"
	exit 1
}

# Extract command line options

# Clear translation variable if it exists and set defaults for others
translation='NABRE'    # Which translation to use
boldwords="false"    # Set words of Jesus in bold
headers="false"      # Include editorial headers
aliases="false"      # Create an alias in the YAML front matter for each chapter title
verbose="true"      # Show download progress for each chapter

# Process command line args
while getopts 'v:beai?h' c
do
	case $c in
		v) translation=$OPTARG ;;
		b) boldwords="true" ;;
		e) headers="true" ;;
		a) aliases="true" ;;
		i) verbose="true" ;;
		h|?) usage ;; 
	esac
done

# Initialize variables
book_counter=0 # Setting the counter to 0
book_counter_max=73 # Setting the max amount to 73, since there are 73 books we want to import


# Book list
## (update to include Catholic books from USCCB: https://bible.usccb.org/bible)
declare -a bookarray # Declaring the Books of the Bible as a list
bookarray=(Genesis Exodus Leviticus Numbers Deuteronomy Joshua Judges Ruth "1 Samuel" "2 Samuel" "1 Kings" "2 Kings" "1 Chronicles" "2 Chronicles" Ezra Nehemiah Tobit Judith Esther "1 Maccabees" "2 Maccabees" Job Psalms Proverbs Ecclesiastes "Song of Songs" Wisdom Sirach Isaiah Jeremiah Lamentations Baruch Ezekiel Daniel Hosea Joel Amos Obadiah Jonah Micah Nahum Habakkuk Zephaniah Haggai Zechariah Malachi Matthew Mark Luke John "Acts of the Apostles"
Romans "1 Corinthians" "2 Corinthians" Galatians Ephesians Philippians Colossians "1 Thessalonians" "2 Thessalonians" "1 Timothy" "2 Timothy" Titus Philemon Hebrews James "1 Peter" "2 Peter" "1 John" "2 John" "3 John" Jude Revelation)

# Book chapter list
declare -a lengtharray # Declaring amount of chapters in each book
lengtharray=(50 40 27 36 34 24 21 4 31 24 22 25 29 36 10 13 14 16 10 16 15 42 150 31 12 8 19 51 66 52 5 6 48 12 14 3 9 1 4 7 3 3 3 2 14 4 28 16 24 21 28 16 16 13 6 6 4 4 5 3 6 4 3 1 13 5 5 3 5 1 1 1 22)

# Abbreviation list
declare -a abbarray # Delaring the abbreviations for each book. You can adapt if you'd like
abbarray=(Gen Ex Lev Num Deut Jos Judg Ruth "1 Sam" "2 Sam" "1 Kings" "2 Kings" "1 Chr" "2 Chr" Ezra Neh Tob Jdt Esth "1 Macc" "2 Macc" Job Ps Prov Eccl Song Wis Sir Isa Jer Lam Bar Ezek Dan Hos Joel Am Obad Jon Mic Nah Hab Zeph Hag Zech Mal Mt Mk Lk Jn Acts Rom "1 Cor" "2 Cor" Gal Eph Phil Col "1 Thess" "2 Thess" "1 Tim" "2 Tim" Titus Philem Heb Jas "1 Pet" "2 Pet" "1 Jn" "2 Jn" "3 Jn" Jude Rev)


if ${verbose} -eq "true"; then
	echo "Starting download of ${translation} Bible."
fi

 # Cycling through the book counter, setting which book and its maxchapter
  for ((book_counter=0; book_counter <= book_counter_max; book_counter++))
  do

	if ${verbose} -eq "true"; then
		echo ""   # Make a new line which the '-n' flag to the echo command prevents.
	fi

    book=${bookarray[$book_counter]}
    maxchapter=${lengtharray[$book_counter]}
    abbreviation=${abbarray[$book_counter]}

	if ${verbose} -eq "true"; then
		echo -n "${book} "
	fi

    for ((chapter=1; chapter <= maxchapter; chapter++))
    do

    	if ${verbose} -eq "true"; then
    		echo -n "."
		fi

((prev_chapter=chapter-1)) # Counting the previous and next chapter for navigation
((next_chapter=chapter+1))

# Exporting
  export_prefix="${abbreviation}-" # Setting the first half of the filename

  if (( ${chapter} < 10 )); then # Making sure single digit numbers are preceded by a 0 for proper sorting
    #statements
    export_number="0${chapter}"
  else
    export_number=${chapter}
  fi

filename=${export_prefix}$export_number # Setting the filename

# Navigation in the note
  if (( ${prev_chapter} < 10 )); then # Turning single into double digit numbers
    #statements
    prev_chapter="0${prev_chapter}"
  fi

  if (( ${next_chapter} < 10 )); then # Turning single into double digit numbers
    #statements
    next_chapter="0${next_chapter}"
  fi

  prev_file=${export_prefix}$prev_chapter # Naming previous and next files
  next_file=${export_prefix}$next_chapter

  # Formatting Navigation and omitting links that aren't necessary
  if [ ${maxchapter} -eq 1 ]; then
    # For a book that only has one chapter
    navigation="[[${book}]]"
  elif [ ${chapter} -eq ${maxchapter} ]; then
    # If this is the last chapter of the book
    navigation="[[${prev_file}|← ${book} ${prev_chapter}]] | [[${book}]]"
  elif [ ${chapter} -eq 1 ]; then
    # If this is the first chapter of the book
    navigation="[[${book}]] | [[${next_file}|${book} ${next_chapter} →]]"
  else
    # Navigation for everything else
    navigation="[[${prev_file}|← ${book} ${prev_chapter}]] | [[${book}]] | [[${next_file}|${book} ${next_chapter} →]]"
  fi

  if ${boldwords} -eq "true" && ${headers} -eq "false"; then
    text=$(ruby bg2md.rb -e -c -b -f -l -r -v "${translation}" ${book} ${chapter}) # This calls the 'bg2md_mod' script
  elif ${boldwords} -eq "true" && ${headers} -eq "true"; then
    text=$(ruby bg2md.rb -c -b -f -l -r -v "${translation}" ${book} ${chapter}) # This calls the 'bg2md_mod' script
  elif ${boldwords} -eq "false" && ${headers} -eq "true"; then
    text=$(ruby bg2md.rb -e -c -f -l -r -v "${translation}" ${book} ${chapter}) # This calls the 'bg2md_mod' script
  else
    text=$(ruby bg2md.rb -e -c -f -l -r -v "${translation}" ${book} ${chapter}) # This calls the 'bg2md_mod' script
  fi


  text=$(echo $text | sed 's/^(.*?)v1/v1/') # Deleting unwanted headers

  # Formatting the title for markdown
  title="# ${book} ${chapter} (${translation})"

  # Navigation format
  export="${title}\n\n$navigation\n***\n\n$text\n\n***\n$navigation"
  if ${aliases} -eq "true"; then
    alias="---\nAliases: [${book} ${chapter}]\n---\n" # Add other aliases or 'Tags:' here if desired. Make sure to follow proper YAML format.
    export="${alias}${export}"
  fi
  

  # Export
  echo -e $export >> "$filename.md"

  # Creating a folder

  ((actual_num=book_counter+1)) # Proper number counting for the folder

  if (( $actual_num < 10 )); then
    #statements
    actual_num="0${actual_num}"
  else
    actual_num=$actual_num
  fi

  folder_name="${actual_num} - ${book}" # Setting the folder name

  # Creating a folder for the book of the Bible if it doesn't exist, otherwise moving new file into existing folder
  mkdir -p "./Scripture (${translation})/${folder_name}"; mv "${filename}".md './Scripture ('"${translation}"')/'"${folder_name}"


done # End of the book exporting loop

  # Create an overview file for each book of the Bible:
  overview_file="links: [[The Bible]]\n# ${book}\n\n[[${abbreviation}-01|Start Reading →]]"
  echo -e $overview_file >> "$book.md"
  #mkdir -p ./Scripture ("${translation}")/"${folder_name}"; mv "$book.md" './Scripture ('"${translation}"')/'"${folder_name}"
  mv "$book.md" './Scripture ('"${translation}"')/'"${folder_name}"

  done

  
  #----------------------------------------------------------------------------------
  # The Output of this text needs to be formatted slightly to fit with use in Obsidian
  # Enable Regex and run find and replace:
    # *Clean up unwanted headers*
      # Find: ^[\w\s]*(######)
      # Replace: \n$1
      # file: *.md
    # Clean up verses
      # Find: (######\sv\d)
      # Replace: \n\n$1\n
      # file: *.md
  #----------------------------------------------------------------------------------

# Not sure if the comments above are still needed, so leaving them for now.

# Tidy up the Markdown files by removing unneeded headers and separating the verses
# with some blank space and an H6-level verse number.
#
# Using a perl one-liner here in order to help ensure that this works across platforms
# since the sed utility works differently on macOS and Linux variants. The perl should
# work consistently.

if ${verbose} -eq "true"; then
	echo ""
	echo "Cleaning up the Markdown files."
fi
# Clear unnecessary headers
find . -name "*.md" -print0 | xargs -0 perl -pi -e 's/#.*(#####\D[1]\D)/#$1/g'

# Format verses into H6 headers
find . -name "*.md" -print0 | xargs -0 perl -pi -e 's/######\s([0-9]\s|[0-9][0-9]\s|[0-9][0-9][0-9]\s)/\n\n###### v$1\n/g'

if ${verbose} -eq "true"; then
echo "Download complete. Markdown files ready for Obsidian import."
fi
