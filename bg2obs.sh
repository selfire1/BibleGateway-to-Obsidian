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
translation='WEB'    # Which translation to use
boldwords="false"    # Set words of Jesus in bold
headers="false"      # Include editorial headers
aliases="false"      # Create an alias in the YAML front matter for each chapter title
verbose="false"      # Show download progress for each chapter

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
biblename="Die Bibel"
# Full names of the books of the Bible
bookarray=("1. Mose" "2. Mose" "3. Mose" "4. Mose" "5. Mose" Josua Richter Ruth "1. Samuel" "2. Samuel" "1. Könige" "2. Könige" "1. Chronik" "2. Chronik" Esra Nehemiah Esther Hiob Psalmen Sprüche Prediger Hohelied Jesaja Jeremia Klagelieder Hesekiel Daniel Hosea Joel Amos Obadja Jona Micha Nahum Habakuk Zephanja Haggai Sacharja Maleachi Matthäus Markus Lukas Johannes Apostelgeschichte Römer "1. Korinther" "2. Korinther" Galater Epheser Philipper Kolosser "1. Thessalonicher" "2. Thessalonicher" "1. Timotheus" "2. Timotheus" Titus Philemon Hebräer Jakobus "1. Petrus" "2. Petrus" "1. Johannes" "2. Johannes" "3. Johannes" Judas Offenbarung)
# Short names of the books of the Bible
abbarray=(1Mo 2Mo 3Mo 4Mo 5Mo Jos Ri Ru 1Sa 2Sa 1Kö 2Kö 1Ch 2Ch Esr Ne Est Hi Ps Spr Pr Hoh Jes Jer Klg Hes Da Hos Joel Am Ob Jon Mi Nah Hab Ze Hag Sach Mal Mat Mar Luk Joh Apg Rö 1Ko 2Ko Gal Eph Php Kol 1Th 2Th 1Ti 2Ti Tit Phm Heb Jak 1Pe 2Pe 1Jo 2Jo 3Jo Jud Off)
# -------------------------------------------

# Book chapter list
lengtharray=(50 40 27 36 34 24 21 4 31 24 22 25 29 36 10 13 10 42 150 31 12 8 66 52 5 48 12 14 3 9 1 4 7 3 3 3 2 14 4 28 16 24 21 28 16 16 13 6 6 4 4 5 3 6 4 3 1 13 5 5 3 5 1 1 1 22)

# Initialise the "The Bible" file for all of the books
echo -e "# ${biblename}\n" >> "${biblename}.md"

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
  export_prefix="${abbreviation} " # Setting the first half of the filename
filename=${export_prefix}$chapter # Setting the filename


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
  title="# ${book} ${chapter}"

  # Navigation format
  export="${title}\n\n$navigation\n***\n\n$text\n\n***\n$navigation"
  if ${aliases} -eq "true"; then
    alias="---\nAliases: [${book} ${chapter}]\n---\n" # Add other aliases or 'Tags:' here if desired. Make sure to follow proper YAML format.
    export="${alias}${export}"
  fi
  

  # Export
  echo -e $export >> "$filename.md"

  # Creating a folder

  folder_name="${book}" # Setting the folder name

  # Creating a folder for the book of the Bible if it doesn't exist, otherwise moving new file into existing folder
  mkdir -p "./${biblename} (${translation})/${folder_name}"; mv "${filename}".md './${biblename} ('"${translation}"')/'"${folder_name}"


done # End of the book exporting loop

  # Create an overview file for each book of the Bible:
  overview_file="links: [[${biblename}]]\n# ${book}\n\n[[${abbreviation} 1|Start Reading →]]"
  echo -e $overview_file >> "$book.md"
  mv "$book.md" "./${biblename} ('"${translation}"')/""${folder_name}"

  # Append the bookname to "The Bible" file
  echo -e "* [[${book}]]" >> "${biblename}.md"
  done

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
find . -name "*.md" -print0 | xargs -0 perl -pi -e 's/######\s([0-9]\s|[0-9][0-9]\s|[0-9][0-9][0-9]\s)/\n\n###### $1\n/g'

# Delete crossreferences
find . -name "*.md" -print0 | xargs -0 perl -pi -e 's/\<crossref intro.*crossref\>//g'

if ${verbose} -eq "true"; then
echo "Download complete. Markdown files ready for Obsidian import."
fi
