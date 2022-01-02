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
bookarray=(Genese Exode Levitique Numbres Deuteronome Josue Juges Ruth "1 Samuel" "2 Samuel" "1 Rois" "2 Rois" "1 Chroniques" "2 Chroniques" Ezra Nehemie Esther Job Psaumes Proverbes Ecclesiaste "Chants de Salomon" Esaie Jeremie Lamentations Ezekiel Daniel Osee Joel Amos Abdias Jonas Michee Nahum Habacuc Sophonie Aggee Zacharie Malachie Matthieu Marc Luc Jean Actes
Romains "1 Corinthiens" "2 Corinthiens" Galates Ephesiens Philippiens Colossiens "1 Thessaloniciens" "2 Thessaloniciens" "1 Timothee" "2 Timothee" Tite Philemon Hebreux Jacques "1 Pierre" "2 Pierre" "1 Jean" "2 Jean" "3 Jean" Jude Apocalypse)

# Book chapter list
declare -a bookarray # Declaring amount of chapters in each book
lengtharray=(50 40 27 36 34 24 21 4 31 24 22 25 29 36 10 13 10 42 150 31 12 8 66 52 5 48 12 14 3 9 1 4 7 3 3 3 2 14 4 28 16 24 21 28 16 16 13 6 6 4 4 5 3 6 4 3 1 13 5 5 3 5 1 1 1 22)

# Abbreviation list
declare -a abbarray # Delaring the abbreviations for each book. You can adapt if you'd like
abbarray=(Gen Exod Lev Nom Deu Jos Jug Rut "1 Sam" "2 Sam" "1 Roi" "2 Roi" "1 Chro" "2 Chro" Ezr Neh Est Job Ps Prov Eccles Can Esa Jer Lam Ezek Dan Ose Joel Am Abd Jona Mic Nah Hab Zeph Hag Zech Mal Matt Mar Luc Jean Act Rom "1 Cor" "2 Cor" Gal Ephes Phil Col "1 Thess" "2 Thess" "1 Tim" "2 Tim" Tite Philem Heb Jacq "1 Pi" "2 Pie" "1 Jean" "2 Jean" "3 Jean" Jude Apo)

# Book synonyms list
declare -a booksynarray # Delaring the abbreviations for each book. You can adapt if you'd like
booksynarray=(Gen Exo Levi Nomb Deut Josu Juge Ruth "1 Samu" "2 Samu" "1 Rois" "2 Rois" "1 Chron" "2 Chron" Ezra Nehe Esth Job Ps Prov Eccles Canti Esai Jere Lame Ezeki Dani Osee Joel Amo Abdi Jonas Mich Nah Hab Zeph Hag Zech Mal Matth Marc Luc Jean Actes Rom "1 Cor" "2 Cor" Gal Ephes Phili Colo "1 Thess" "2 Thess" "1 Tim" "2 Tim" Tite Philem Heb Jacques "1 Pi" "2 Pie" "1 Jean" "2 Jean" "3 Jean" Jude Apoc)

# Book Abbreviation synonyms list
declare -a abbsynarray # Delaring the abbreviations for each book. You can adapt if you'd like
abbsynarray=(Gen Exod Lev Num Deut Josh Judg Ruth "1 Sam" "2 Sam" "1 Kings" "2 Kings" "1 Chron" "2 Chron" Ezr Neh Esth Job Ps Prov Eccles Song Isa Jer Lam Ezek Dan Hos Joel Am Obad Jonah Micah Nah Hab Zeph Hag Zech Mal Matt Mark Luke John Acts Rom "1 Cor" "2 Cor" Gal Ephes Phil Col "1 Thess" "2 Thess" "1 Tim" "2 Tim" Titus Philem Heb James "1 Pet" "2 Pet" "1 John" "2 John" "3 John" Jude Rev)

# Book authors list
declare -a authorarray # Delaring the abbreviations for each book. You can adapt if you'd like
authorarray=(Moses Moses Moses Moses Moses "Joshua exept death parts" "Samuel, Mathan, Gad" "Samuel, Nathan, Gad" "Samuel, Nathan, Gad" "Samuel, Nathan, Gad" Jeremiah Jeremiah Ezra Ezra Ezr "Nehemiah, Ezra" "Mordecai (Mardoché)" Job "David, Asaph, Ezra, the sons of Korah, Heman, Ethan, Moses and unnamed authors" "Solomon, Agur and Lemuel" Solomon Solomon Isaiah Jeremiah Jeremiah Ezekiel Daniel Hosea Joel Amos Obadiah Jonah Micah Nahum Habakkuk Zephaniah Haggai Zechariah Malachi Matthew "John Mark" Luke "John, the Apostle" "Luke" Paul Paul Paul Paul Paul Paul Paul Paul Paul Paul Paul Paul Paul "Paul, Luke, Barnabas, Apollos" "James" Peter Peter "John, the Apostle" "John, the Apostle" "John, the Apostle" "Jude, the brother of Jesus and James" "John, the Apostle")

# Book date written list
declare -a datewritenarray # Delaring the abbreviations for each book. You can adapt if you'd like
datewritenarray=("1445-1405 BC" "1445-1405 BC" "1445-1405 BC" "1445-1405 BC" "1445-1405 BC" "1405-1385 BC" "1043 BC" "1030-1010 BC" "931-722 BC" "931-722 BC" "561-538 BC" "561-538 BC" "450-430 BC" "450-430 BC" "100 BC-AD 100" "424-400 BC" "450-331 BC" "Considered earliest, but date unknown" "1410-450 BC" "971-686 BC" "940-931 BC" "971-965 BC" "700-681 BC" "586-570 BC" "586 BC" "590-570 BC" "536-530 BC" "750-710 BC" "835-796 BC" "750 BC" "850-840 BC" "775 BC" "735-710 BC" "650 BC" "615-605 BC" "635-625 BC" "520 BC" "480-470 BC" "433-424 BC" "AD 50-60" "AD 50-60" "AD 60-61" "AD 80-90" "AD 62" "AD 56" "AD 55" "AD 55-56" "AD 49-50" "AD 60-62" "AD 60-62" "AD 60-62" "AD 51" "AD 51-52" "AD 62-64" "AD 66-67" "AD 62-64" "AD 60-62" "AD 67-69" "AD 44-49" "AD 64-65" "AD 67-68" "AD 90-95" "AD 90-95" "AD 90-95" "AD 68-70" "AD 94-96")


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
    booksyn=${booksynarray[$book_counter]}
    maxchapter=${lengtharray[$book_counter]}
    abbreviation=${abbarray[$book_counter]}
    abbreviationsyn=${abbsynarray[$book_counter]}
    author=${authorarray[$book_counter]}
    datewrite=${datewritenarray[$book_counter]}

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
  title="# ${book} ${chapter}"

  # Navigation format
  export="${title}\n\n$navigation\n***\n\n$text\n\n***\n$navigation"
  if ${aliases} -eq "true"; then
    alias="---\nAliases: [${book} ${chapter}, ${booksyn} ${chapter}, ${abbreviationsyn} ${chapter}]\nAuthor: $author\nDate_written: $datewrite\n---\n" # Add other aliases or 'Tags:' here if desired. Make sure to follow proper YAML format.
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
  overview_file="links: [[The Bible]]\nAliases: [${book}, ${booksyn}, ${abbreviationsyn}]\nAuthor: $author\nDate_written: $datewrite\n# ${book}\n\n[[${abbreviation}-01|Start Reading →]]"
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
