# BibleGateway-to-Obsidian
## ⚠️ Disclaimers
By default, the version is set to the [WEB Bible](https://worldenglish.bible/). You can change the version but **must honour the copyright standards** of different translations of the Bible (See for example [BibleGateway's overview](https://www.biblegateway.com/versions/)).

Using the script with some versions is **clearly breaking copyright**. The script is not intended for such usage.

For example, for the ESV from https://www.esv.org/resources/esv-global-study-bible/copyright-page/:

> "The ESV text may be quoted (in written, visual, or electronic form) up to and inclusive of five hundred (500) consecutive verses without express written permission of the publisher, provided that the verses quoted do not amount to more than one-half of any one book of the Bible or its equivalent measured in bytes and provided that the verses quoted do not account for twenty-five percent (25%) or more of the total text of the work in which they are quoted."

The NET translation, however has very generous copyright rules: https://netbible.com/copyright/. It appears to be permissible to use for personal study.

This is not affiliated to, or approved by, BibleGateway.com. In my understanding it fits into the [conditions of usage](https://support.biblegateway.com/hc/en-us/articles/360001398808-How-do-I-get-permission-to-use-or-reprint-Bible-content-from-Bible-Gateway-?), but I make no guarantee regarding the usage of the script, it is at your own discretion.
## Changes in this fork
This fork fixes some problems where some command-line options weren't being followed, and a problem where newlines would get stripped out of the final file.

It also modifies the navigation to be useful with logseq (which uses typical markdown for links like `[the text]([[the-linked-to-page]])` with the first part being what is seen and the second part being the link itself).
## About
This script adapts [jgclark's BibleGateway-to-Markdown](https://github.com/jgclark/BibleGateway-to-Markdown) script to export for use in [Obsidian](https://obsidian.md/). It accompanies a [Bible Study in Obsidian Kit](https://forum.obsidian.md/t/bible-study-in-obsidian-kit-including-the-bible-in-markdown/12503?u=selfire) that gets you hands-on with using Scripture in your personal notes.

What the script does is fetch the text from [Bible Gateway](https://www.biblegateway.com/) and save it as a formatted markdown file. Each chapter is saved as one file and navigation between files as well as a book-file is automatically created. All the chapter files of a book are saved in its numbered folder.

This script is intended to be as simple as possible to use, even if you have no idea about scripting. If you have any questions, please reach out to me either on GitHub or Discord (`selfire#3095`).
## Translations
This repository is also available in
* 🇬🇧 [English](https://github.com/selfire1/BibleGateway-to-Obsidian/tree/master)
* 🇫🇷 [French](https://github.com/selfire1/BibleGateway-to-Obsidian/tree/translation-fr) (Merci `@fullbright`!)
* 🇩🇪 [German](https://github.com/selfire1/BibleGateway-to-Obsidian/tree/translation-de)

## Installation
Here are the tools we are going to use:
* Our command line (Terminal)
* On Windows you might need to [install perl](https://www.perl.org/get.html).

## Setting ruby up
### Updating
In order to run the scripts, we will need to install ruby. Ruby comes pre-installed on macOS, but if you run into issues [update to the latest version](https://stackify.com/install-ruby-on-your-mac-everything-you-need-to-get-going/).

### Downloading BibleGateway-to-Markdown.rb
Follow the instructions to download and set up [jgclark's BibleGateway-to-Markdown](https://github.com/jgclark/BibleGateway-to-Markdown).

## Usage
### 1. Install scripts
Place both scripts (`bg2md.rb` and `bg2obs.sh`) in the same directory, open your terminal application, and navigate to that directory with commands like the following:

* `pwd` Show your current directory
* `ls` List all contents in the current directory
* `cd` Enter a subdirectory (e.g., `cd Desktop`)
* `cd ..` Brings you 'up' one directory

### 2. Run the script
Once you have navigated to the directory containing both scripts, run `bash bg2obs.sh`. This will run the bash script.

`NOTE`: In this directory, a folder called `Scripture` with subfolders like `Genesis`, `Exodus` and so on will be created.

Several options are available via command-line switches. Type `bash bg2obs.sh -h` at any time to display them.

#### Script option summary
| Option | Description |
| ------ | ----------- |
| `-v [VERSION]` | Specify the version of the Bible to download (default is WEB) |
| `-b` | Set words of Jesus in bold (default is Off)|
| `-e` | Include editorial headers (default is Off)|
| `-a` | Create an alias in the YAML front matter with a more user-friendly chapter title  (e.g., "Genesis 1") (default is Off)|
| `-i` | Show progress information while the script is running (i.e. "verbose" mode) (default is Off)|
| `-c` | Include *inline* navigation for the [breadcrumbs](https://github.com/SkepticMystic/breadcrumbs) plugin (e.g. 'up', 'next','previous') (default is Off)|
| `-y` | Include navigation for the breadcrumbs plugin in the *frontmatter* (YAML) (default is Off)|
| `-h` | Display help |

#### Example usage
| Command | Description |
| ------- | ----------- | 
|`bash bg2obs.sh -i -v NET` | Download a copy of the NET Bible with no other options.|
|`bash bg2obs.sh -b` | Download a copy of the WEB Bible (default) with Jesus' words in bold. |
|`bash bg2obs.sh -y` | Download a copy of the WEB Bible (default) with breadcrumbs navigation in the frontmatter. |
|`bash bg2obs.sh -v NET -beacyi` | Download a copy of the NET Bible with all options enabled.|

### 3. Format the text in a text editor

Some cross references are sometimes still included, run `\<crossref intro.*crossref\>` to delete.

**There you go!** Now, just move the "Scripture" folder into your Obsidian vault. You can use the provided `The Bible.md` file as an overview file.

## Translations
This script downloads the [World English Bible](https://worldenglish.bible/) by default. If you want to download a different translation, specify the version using the `-v` command-line switch as documented above. The list of abbreviations is available on the [Bible Gateway](https://www.biblegateway.com) site under the version drop-down menu in the search bar.  Make sure to honour copyright guidelines. The script has not been tested with all versions of the Bible available at Bible Gateway, though most of the more commonly-used ones should work.

A fork of this repo supports Catholic translations: [mkudija/BibleGateway-to-Obsidian-Catholic](https://github.com/mkudija/BibleGateway-to-Obsidian-Catholic).

## Troubleshooting 🐛
Below are common issues when using the script. If this still doesn't solve your issue, there are some place to get help:
* The [Help and Support thread](https://forum.obsidian.md/t/bible-study-kit-in-obsidian-scripts-help-and-support/31069/2) for this script in the Obsidian Forums. (I am somewhat less active there, but plenty of folks are happy to help out!)
* Create an [issue](https://github.com/selfire1/BibleGateway-to-Obsidian/issues) on GitHub. This is my preferred way to keep track of what needs fixing.
* Also, feel free to [get in touch](https://joschuasgarden.com/Contact+me) and I will attempt to fix it!

### Problems loading ruby/gems
An error like this indicates ruby or the gems aren't installed properly: `in require: cannot load such file -- colorize (LoadError)`

**Solutions**
* Have a look at the [bg2md installation guide](https://github.com/jgclark/BibleGateway-to-Markdown/tree/7aaa4cdaba5d8ebb2e7e3fa5ace7de96c1534846#installation) to make sure you installed ruby and gems properly.
* Run the gem install with admin privileges: `sudo gem install colorize optparse clipboard`.
* Re-install ruby and gems.

### The first chapter of the book repeats
☑️ Use [version 1.4.3](https://github.com/jgclark/BibleGateway-to-Markdown/tree/d693e85bba94122a2f46bec3ff9487333bccfdbf) of jgclark's script instead of the newest version.

## Contributing
Pull requests are welcome.
You can help me keep creating tools like this by [buying me a coffee](https://www.buymeacoffee.com/joschua).  ☕️

<a href="https://www.buymeacoffee.com/joschua" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height= "48" width="173"></a>

### Translations
You can contribute by translating this script into your language.

- [ ] Translate name of the Bible, its books and abbreviations ([line 62](https://github.com/selfire1/BibleGateway-to-Obsidian/blob/97f873132dceb2504b765056914bd3dd927f6691/bg2obs.sh#L62))
- [ ] Optional: Translate `README.md`

Pull requests are welcome, or send me a message and I will implement your translation.
