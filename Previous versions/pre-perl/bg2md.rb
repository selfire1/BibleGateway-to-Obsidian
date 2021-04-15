#!/usr/bin/ruby
#----------------------------------------------------------------------------------
# BibleGateway passage lookup and parser to Markdown
# - Jonathan Clark, v1.4.0, 1.2.2021
#----------------------------------------------------------------------------------
# Uses BibleGateway.com's passage lookup tool to find a passage and turn it into
# Markdown usable in other ways. It passes 'reference' through to the BibleGateway
# parser to work out what range of verses should be included.
# The reference term is concatenated to remove spaces, meaning it doesn't need to be
# 'quoted'. It does not yet support multiple passages.
#
# The Markdown output includes:
# - passage reference
# - version abbreviation
# - sub-headings
# - passage text
# Optionally also:
# - verse (and chapter) numbers
# - footnotes
# - cross-refs
# - copyright info
#
# The output also gets copied to the clipboard.
# When the 'Lord' is shown with small caps (in OT), it's output as 'LORD'.
# When the original is shown red letter (words of Jesus), this is rendered in bold instead.
#
# In what is returned from BibleGateway it ignores:
# - all <h2> meta-chapter titles, <hr />, most <span>s
#----------------------------------------------------------------------------------
# TODO: Decide whether to support returning more than one passage (e.g. "Mt1.1;Jn1.1")
#----------------------------------------------------------------------------------
# Ruby String manipulation docs: https://ruby-doc.org/core-2.7.1/String.html#method-i-replace
#----------------------------------------------------------------------------------
# Key parts of HTML Page structure currently returned by BibleGateway:
# - lots of header guff until <body ...
# - then lots of menu, login, and search options
# - then more options
# - finally 650 lines in ...
# - <h1 class="passage-display">
# - <div class='bcv'><div class="dropdown-display"><div class="dropdown-display-text">John 3:1-3</div></div></div> ...
# - <div class='translation'><div class="dropdown-display"><div class="dropdown-display-text">New English Translation (NET Bible)</div></div></div></h1>
# - NB: or Jude has: <h1 class="passage-display"> <span class="passage-display-bcv">Jude</span> <span class="passage-display-version">New International Version - UK (NIVUK)</span></h1>
# - hundreds of uninteresting translation <option>s
# - <p> <span id="en-NLT-28073" class="text Rom-7-20"><sup class="versenum">20 </sup>
#   (or in the case of MSG: <sup class="versenum">5-8</sup>")
# - <h3><span id="en-NET-26112" class="text John-3-1">Conversation with Nicodemus</span></h3> ...
# - <p class="chapter-1"><span class="text John-3-1"><span class="chapternum">3 </span> ...
# - <sup data-fn='...' class='footnote' ... >
#   Pharisee<sup data-fn='#fen-NET-26112a' class='footnote' data-link='[&lt;a href=&quot;#fen-NET-26112a&quot; title=&quot;See footnote a&quot;&gt;a&lt;/a&gt;]'>[<a href="#fen-NET-26112a" title="See footnote a">a</a>]</sup> named Nicodemus, who was a member of the Jewish ruling council,<sup data-fn='#fen-NET-26112b' class='footnote' data-link='[&lt;a href=&quot;#fen-NET-26112b&quot; title=&quot;See footnote b&quot;&gt;b&lt;/a&gt;]'>[<a href="#fen-NET-26112b" title="See footnote b">b</a>]</sup> </span> <span id="en-NET-26113" class="text John-3-2"><sup class="versenum">2 </sup>came to Jesus<sup data-fn='#fen-NET-26113c' class='footnote' data-link='[&lt;a href=&quot;#fen-NET-26113c&quot; title=&quot;See footnote c&quot;&gt;c&lt;/a&gt;]'>[<a href="#fen-NET-26113c" title="See footnote c">c</a>]</sup> at night<sup data-fn='#fen-NET-26113d' class='footnote' data-link='[&lt;a href=&quot;#fen-NET-26113d&quot; title=&quot;See footnote d&quot;&gt;d&lt;/a&gt;]'>[<a href="#fen-NET-26113d" title="See footnote d">d</a>]</sup> and said to him, “Rabbi, we know that you are a teacher who has come from God. For no one could perform the miraculous signs<sup data-fn='#fen-NET-26113e' class='footnote' data-link='[&lt;a href=&quot;#fen-NET-26113e&quot; title=&quot;See footnote e&quot;&gt;e&lt;/a&gt;]'>[<a href="#fen-NET-26113e" title="See footnote e">e</a>]</sup> that you do unless God is with him.” </span> <span id="en-NET-26114" class="text John-3-3"><sup class="versenum">3 </sup>Jesus replied,<sup data-fn='#fen-NET-26114f' class='footnote' data-link='[&lt;a href=&quot;#fen-NET-26114f&quot; title=&quot;See footnote f&quot;&gt;f&lt;/a&gt;]'>[<a href="#fen-NET-26114f" title="See footnote f">f</a>]</sup> “I tell you the solemn truth,<sup data-fn='#fen-NET-26114g' class='footnote' data-link='[&lt;a href=&quot;#fen-NET-26114g&quot; title=&quot;See footnote g&quot;&gt;g&lt;/a&gt;]'>[<a href="#fen-NET-26114g" title="See footnote g">g</a>]</sup> unless a person is born from above,<sup data-fn='#fen-NET-26114h' class='footnote' data-link='[&lt;a href=&quot;#fen-NET-26114h&quot; title=&quot;See footnote h&quot;&gt;h&lt;/a&gt;]'>[<a href="#fen-NET-26114h" title="See footnote h">h</a>]</sup> he cannot see the kingdom of God.”<sup data-fn='#fen-NET-26114i' class='footnote' data-link='[&lt;a href=&quot;#fen-NET-26114i&quot; title=&quot;See footnote i&quot;&gt;i&lt;/a&gt;]'>[<a href="#fen-NET-26114i" title="See footnote i">i</a>]</sup> </span> </p>
# - <h4>Footnotes</h4>
#   <li id="..."><a href="#..." title="Go to John 3:1">John 3:1</a> <span class='footnote-text'>..text....</span></li>
# - other uninteresting stuff
# - <div class="publisher-info-bottom with-bga">...<a href="...">New English Translation</a> (NET)</strong> <p>NET Bible® copyright ©1996-2017 by Biblical Studies Press, L.L.C. http://netbible.com All rights reserved.</p></div></div>
#
# NB:
# - The character before the verse number in <sup class="versenum">20 </sup> is
#   actually Unicode Character U+00A0 No-Break Space (NBSP). This was a tough one
#   to find! These are converted to ordinary ASCII spaces.
# - At end-2020, NIV has cross-references, but NIVUK does not. The part in the passage is:
#       <sup class='crossreference' data-cr='#cen-NIV-28102S' data-link='(&lt;a href=&quot;#cen-NIV-28102S&quot;
#       title=&quot;See cross-reference S&quot;&gt;S&lt;/a&gt;)'>(<a href="#cen-NIV-28102S" 
#       title="See cross-reference S">S</a>)</sup>
#   and the later detail is:
#       <li id="cen-NIV-28102S"><a href="#en-NIV-28102" title="Go to Romans 7:10">Romans 7:10</a> : <a
#       class="crossref-link"
#       href="/passage/?search=Leviticus+18%3A5%2CLuke+10%3A26-Luke+10%3A28%2CRomans+10%3A5%2CGalatians+3%3A12&version=NIV"
#       data-bibleref="Leviticus 18:5, Luke 10:26-Luke 10:28, Romans 10:5, Galatians 3:12">Lev 18:5; Lk 10:26-28;
#       S Ro 10:5; Gal 3:12</a></li>
# - You can run this in -test mode, which uses a local file as the HTML input,
#   to avoid over-using the BibleGateway service.
#----------------------------------------------------------------------------------
VERSION = '1.4.0'.freeze

# require 'uri' # for dealing with URIs
require 'net/http' # for handling URIs and requests. More details at https://ruby-doc.org/stdlib-2.7.1/libdoc/net/http/rdoc/Net/HTTP.html
require 'optparse' # more details at https://docs.ruby-lang.org/en/2.1.0/OptionParser.html 'gem install OptionParser'
require 'colorize' # 'gem install colorize'
require 'clipboard' # for writing to clipboard

# Setting variables to tweak
DEFAULT_VERSION = 'NET'.freeze

# Regular expressions used to detect various parts of the HTML to keep and use
START_READ_CONTENT_RE = '<h1 class=[\'"]passage-display[\'"]>'.freeze # seem to see both versions of this -- perhaps Jude is an outlier?
END_READ_CONTENT_RE   = '^<script '.freeze
# Match parts of lines which actually contain passage text
PASSAGE_RE = '(<p><span id=|<p class=|<p>\s?<span class=|<h3).*?(?:<\/p>|<\/h3>)'.freeze
# Match parts of lines which actually contain passage text -- this uses non-matching groups to allow both options and capture
MATCH_PASSAGE_RE = '((?:<p><span id=|<p class=|<p>\s?<span class=|<h3).*?(?:<\/p>|<\/h3>))'.freeze
REF_RE = '(<div class=\'bcv\'><div class="dropdown-display"><div class="dropdown-display-text">|<span class="passage-display-bcv">).*?(<\/div>|<\/span>)'.freeze
MATCH_REF_RE = '(?:<div class=\'bcv\'><div class="dropdown-display"><div class="dropdown-display-text">|<span class="passage-display-bcv">)(.*?)(?:<\/div>|<\/span>)'.freeze
VERSION_RE = '(<div class=\'translation\'><div class="dropdown-display"><div class="dropdown-display-text">|<span class="passage-display-version">).*?(<\/div>|<\/span>)'.freeze
MATCH_VERSION_RE = '(?:<div class=\'translation\'><div class="dropdown-display"><div class="dropdown-display-text">|<span class="passage-display-version">)(.*?)(?:<\/div>|<\/span>)'.freeze
FOOTNOTE_RE = '<span class=\'footnote-text\'>.*?<\/span>'.freeze
MATCH_FOOTNOTE_RE = 'title=.*?>(.*?)<\/a>( )<span class=\'footnote-text\'>(.*)<\/span><\/li>'.freeze
CROSSREF_RE = '<a class="crossref-link".*?">.*?</a></li>'.freeze
MATCH_CROSSREF_RE = '<a class="crossref-link".*?">(.*)?</a></li>'.freeze
COPYRIGHT_STRING_RE = '<div class="publisher-info'.freeze
MATCH_COPYRIGHT_STRING_RE = '<p>(.*)<\/p>'.freeze

#=======================================================================================
# Main logic
#=======================================================================================

# Setup program options
opts = {}
opt_parser = OptionParser.new do |o|
  o.banner = 'Usage: bg2md.rb [options] reference'
  o.separator ''
  opts[:boldwords] = false
  o.on('-b', '--boldwords', 'Make the words of Jesus in markdown bold') do
    opts[:boldwords] = true
  end
  opts[:copyright] = true
  o.on('-c', '--copyright', 'Exclude copyright notice') do
    opts[:copyright] = false
  end
  opts[:headers] = true
  o.on('-e', '--headers', 'Exclude editorial headers') do
    opts[:headers] = false
  end
  opts[:footnotes] = true
  o.on('-f', '--footnotes', 'Exclude footnotes') do
    opts[:footnotes] = false
  end
  o.on('-h', '--help', 'Show help') do
    puts o
    exit
  end
  opts[:verbose] = false
  o.on('-i', '--info', 'Show information as I work') do
    opts[:verbose] = true
  end
  opts[:newline] = false
  o.on('-l', '--newline', 'Start chapters and verses on newline with H5 or H6 heading') do
    opts[:newline] = true
  end
  opts[:numbering] = true
  o.on('-n', '--numbering', 'Exclude verse and chapter numbers') do
    opts[:numbering] = false
  end
  opts[:crossrefs] = true
  o.on('-r', '--crossrefs', 'Exclude cross-references') do
    opts[:crossrefs] = false
  end
  opts[:filename] = ''
  o.on('-t', '--test FILENAME', "Pass HTML from FILENAME instead of live lookup. 'reference' must still be given, but will be ignored.") do |f|
    opts[:filename] = f
  end
  opts[:version] = DEFAULT_VERSION
  o.on('-v', '--version VERSION', 'Select Bible version to lookup (default:' + DEFAULT_VERSION + ')') do |v|
    opts[:version] = v
  end
end
opt_parser.parse! # parse out options, leaving file patterns to process

# Get reference given on command line
ref = ARGV.join() # ARGV[0] 
if ref.nil? # or ref.empty?
  puts opt_parser # show help
  exit
end

# Form URL string to do passage lookup
uri = URI 'https://www.biblegateway.com/passage/'
params = { interface: 'print', version: opts[:version], search: ref }
uri.query = URI.encode_www_form params

# Read the full page contents, but only save the very small interesting part
begin
  input_line_count = 0
  if opts[:filename].empty?
    # If we're not running with test data: Call BG and check response is OK
    puts "Calling URL <#{uri}> ...".colorize(:yellow) if opts[:verbose]
    response = Net::HTTP.get_response(uri)
    case response
    when Net::HTTPSuccess then
      ff = response.body.force_encoding('utf-8') # otherwise returns as ASCII-8BIT ??
      f = ff.split(/\R/) # split on newline or CR LF
      n = 0
      input_lines = []
      indent_spaces = ''
      in_interesting = false
      f.each do |line|
        # see if we've moved into the interesting part
        if line =~ /#{START_READ_CONTENT_RE}/
          in_interesting = true
          # create 'indent_spaces' with the number of whitespace characters the first line is indented by
          # line.scan(/^(\s*)/) { |m| indent_spaces = m.join }
        end
        # see if we've moved out of the interesting part
        in_interesting = false if line =~ /#{END_READ_CONTENT_RE}/
        next unless in_interesting

        # save this line, having chopped off the 'indent' amount of leading whitespace,
        # and checked it isn't empty
        updated_line = line.strip # delete_prefix(indent_spaces).chomp
        next if updated_line.empty?

        input_lines[n] = updated_line
        n += 1
      end
      input_line_count = n
    else
      puts "--> Error: #{response.message} (#{response.code})".colorize(:red)
      exit
    end
  else
    # If we're running with TEST data: read from local HTML file instead
    n = 0
    input_lines = []
    indent_spaces = ''
    in_interesting = false
    puts "Using test data from '#{opts[:filename]}'...".colorize(:yellow) if opts[:verbose]
    f = File.open(opts[:filename], 'r', encoding: 'utf-8')
    f.each_line do |line|
      # see if we've moved into the interesting part
      if line =~ /#{START_READ_CONTENT_RE}/
        in_interesting = true
        # create 'indent_spaces' with the number of whitespace characters the first line is indented by
        # line.scan(/^(\s*)/) { |m| indent_spaces = m.join }
      end
      # see if we've moved out of the interesting part
      in_interesting = false if line =~ /#{END_READ_CONTENT_RE}/
      next unless in_interesting

      # save this line, having chopped off the 'indent' amount of leading whitespace,
      # and checked it isn't empty
      updated_line = line.strip # delete_prefix(indent_spaces).chomp
      next if updated_line.empty?

      input_lines[n] = updated_line
      n += 1
    end
    input_line_count = n
  end
end

if input_line_count.zero?
  puts 'Error: found no useful lines in HTML data, so stopping.'.colorize(:red)
  exit
end

# Join adjacent lines together
lump = input_lines[0] # jump start this
n = 1
while n < input_line_count
  line = input_lines[n]
  n += 1
  # add line to 'lump' if it's not one of hundreds of version options
  lump = lump + ' ' + line.strip if line !~ %r{<option.*</option>}
end
puts "Pass 1: 'Interesting' text = #{input_line_count} lines, #{lump.size} bytes." if opts[:verbose]

if lump.empty?
  puts 'Error: found no \'interesting\' text, so stopping.'.colorize(:red)
  exit
end

# Then break apart on </h1>, </h4>, </ol>, </li>, </p> to make parsing logic easier
working_lines = []
w = 0
lump.scan(%r{(.*?(</p>|</li>|</ol>|</h1>|</h4>))}) do |m|
  break if m[0].nil?

  working_lines[w] = m[0].strip
  # puts (working_lines[w]).to_s if opts[:verbose]
  w += 1
end
working_line_count = w + 1
puts "Pass 2: Now has #{working_line_count} working lines." if opts[:verbose]

# Now read through the saved lines, saving out the various component parts
full_ref = ''
copyright = ''
passage = ''
version = ''
footnotes = []
number_footnotes = 0 # NB: counting from 0
crossrefs = []
number_crossrefs = 0 # NB: counting from 0
n = 0 # NB: counting from 1
while n < working_line_count
  line = working_lines[n]
  # puts(working_lines[n]).to_s.colorize(:green) if opts[:verbose]
  # Extract full reference
  line.scan(/#{MATCH_REF_RE}/) { |m| full_ref = m.join } if line =~ /#{REF_RE}/
  # Extract version title
  line.scan(/#{MATCH_VERSION_RE}/) { |m| version = m.join } if line =~ /#{VERSION_RE}/
  # Extract passage
  line.scan(/#{MATCH_PASSAGE_RE}/) { |m| passage += m.join } if line =~ /#{PASSAGE_RE}/
  # Extract copyright
  line.scan(/#{MATCH_COPYRIGHT_STRING_RE}/) { |m| copyright = m.join } if line =~ /#{COPYRIGHT_STRING_RE}/
  # Extract footnote
  if line =~ /#{FOOTNOTE_RE}/
    line.scan(/#{MATCH_FOOTNOTE_RE}/) do |m|
      footnotes[number_footnotes] = m.join
      number_footnotes += 1
    end
  end
  # Extract crossref
  if line =~ /#{CROSSREF_RE}/
    line.scan(/#{MATCH_CROSSREF_RE}/) do |m|
      crossrefs[number_crossrefs] = m.join
      number_crossrefs += 1
    end
  end
  n += 1
end
puts if opts[:verbose]

# Only continue if we have found the passage
if passage.empty?
  puts 'Error: cannot parse passage text, so stopping.'.colorize(:red)
  exit
end
puts passage.colorize(:yellow) if opts[:verbose]
puts if opts[:verbose]

#---------------------------------------
# Now process the main passage text
#---------------------------------------
# remove UNICODE U+00A0 (NBSP) characters (they are only used in BG for formatting not content)
passage.gsub!(/\u00A0/, '') # FIXME: ?? error as getting ASCII-8BIT string when using live data
# replace HTML &nbsp; and &amp; elements with ASCII equivalents
passage.gsub!(/&nbsp;/, ' ')
passage.gsub!(/&amp;/, '&')
# replace smart quotes with dumb ones
passage.gsub!(/“/, '"')
passage.gsub!(/”/, '"')
passage.gsub!(/‘/, '\'')
passage.gsub!(/’/, '\'')
# replace en dash with markdwon equivalent
passage.gsub!(/—/, '--')

# ignore <h1> as it doesn't always appear (e.g. Jude)
passage.gsub!(%r{<h1.*?</h1>\s*}, '')
# ignore all <h2>book headings</h2>
passage.gsub!(%r{<h2>.*?</h2>}, '')
# ignore all <hr />
passage.gsub!(%r{<hr />}, '')
# simplify verse/chapters numbers (or remove entirely if that option set)
if opts[:numbering]
  # Now see whether to start chapters and verses as H5 or H6 
  if opts[:newline]
    # Extract the contents of the 'versenum' class (which should just be numbers, but we're not going to be strict)
    passage.gsub!(%r{<sup class="versenum">\s*(\d+-?\d?)\s*</sup>}, "\n###### \\1 ")
    # verse number '1' seems to be omitted if start of a new chapter, and the chapter number is given.
    passage.gsub!(%r{<span class="chapternum">\s*(\d+)\s*</span>}, "\n##### Chapter \\1\n###### 1 ")
  else
    # Extract the contents of the 'versenum' class (which should just be numbers, but we're not going to be strict)
    passage.gsub!(%r{<sup class="versenum">\s*(\d+-?\d?)\s*</sup>}, '\1 ')
    # verse number '1' seems to be omitted if start of a new chapter, and the chapter number is given.
    passage.gsub!(%r{<span class="chapternum">\s*(\d+)\s*</span>}, '\1:1 ')
  end
else
  passage.gsub!(%r{<sup class="versenum">.*?</sup>}, '')
  passage.gsub!(%r{<span class="chapternum">.*?</span>}, '')
end
# Modify various things to their markdown equivalent
passage.gsub!(/<p.*?>/, "\n") # needs double quotes otherwise it doesn't turn this into newline
passage.gsub!(%r{</p>}, '')
# If we have editorial headers (which come from <h3> elements) then only output if we want them
if opts[:headers]
  passage.gsub!(/<h3.*?>\s*/, "\n\n## ")
else
  passage.gsub!(/<h3.*?>\s*/, '')
end
passage.gsub!(%r{</h3>}, '')
passage.gsub!(/<b>/, '**')
passage.gsub!(%r{</b>}, '**')
passage.gsub!(/<i>/, '_')
passage.gsub!(%r{</i>}, '_')
passage.gsub!(%r{<br />}, "  \n") # use two trailling spaces to indicate line break but not paragraph break
# Change the small caps around OT 'Lord' and make caps instead
passage.gsub!(%r{<span style="font-variant: small-caps" class="small-caps">Lord</span>}, 'LORD')
# Change the red text for Words of Jesus to be bold instead (if wanted)
passage.gsub!(%r{<span class="woj">(.*?)</span>}, '**\1**') if opts[:boldwords]
# simplify footnotes (or remove if that option set). Complex so do in several stages.
if opts[:footnotes]
  passage.gsub!(/<sup data-fn=\'.*?>/, '<sup>')
  passage.gsub!(%r{<sup>\[<a href.*?>(.*?)</a>\]</sup>}, '[^\1]')
else
  passage.gsub!(%r{<sup data-fn.*?<\/sup>}, '')
end
# simplify cross-references (or remove if that option set).
if opts[:crossrefs]
  passage.gsub!(%r{<sup class='crossreference'.*?See cross-reference (\w)+.*?</sup>}, '[^\1]')
else
  passage.gsub!(%r{<sup class='crossreference'.*?</sup>}, '')
end
# replace <a>...</a> elements with simpler [...]
passage.gsub!(/<a .*?>/, '[')
passage.gsub!(%r{</a>}, ']')
# take out some <div> and </div> elements
passage.gsub!(/<div class="footnotes">/, '')
passage.gsub!(/<div class="poetry.*?>/, '')
passage.gsub!(%r{\s*</div>}, '')
# take out all <span> and </span> elements (needs to come after chapternum spans)
passage.gsub!(/<span .*?>/, '')
passage.gsub!(%r{</span>}, '')
passage = passage.strip # remove leading or trailing whitespace removed

# If we want footnotes, process each footnote item, simplifying
if number_footnotes.positive?
  i = 0
  footnotes.each do |ff|
    # Change all <b>...</b> to *...* and <i>...</i> to _..._
    ff.gsub!(/<b>/, '**')
    ff.gsub!(%r{</b>}, '**')
    ff.gsub!(/<i>/, '_')
    ff.gsub!(%r{</i>}, '_')
    # replace all <a class="bibleref" ...>ref</a> with [ref]
    ff.gsub!(/<a .*?>/, '[')
    ff.gsub!(%r{</a>}, ']')
    # Remove all <span>s around other languages
    ff.gsub!(/<span .*?>/, '')
    ff.gsub!(%r{</span>}, '')
    footnotes[i] = ff
    i += 1
  end
end

# Create an alphabetical hash of numbers (Mod 26) to mimic their
# footnote numbering scheme (a..zz). Taken from
# https://stackoverflow.com/questions/14632304/generate-letters-to-represent-number-using[math - Generate letters to represent number using ruby? - Stack Overflow](https://stackoverflow.com/questions/14632304/generate-letters-to-represent-number-using-ruby)
hf = {}
('a'..'zz').each_with_index { |w, i| hf[i + 1] = w }
# Create an alphabetical hash of numbers (Mod 26) to mimic their
# cross-ref numbering scheme (A..ZZ)
hc = {}
('A'..'ZZ').each_with_index { |w, i| hc[i + 1] = w }

# Finally, prepare the output
output_text = "# #{full_ref} (#{version})\n"
output_text += "#{passage}\n\n"
if number_footnotes.positive? && opts[:footnotes]
  output_text += "### Footnotes\n"
  i = 1
  footnotes.each do |ff|
    output_text += "[^#{hf[i]}]: #{ff}\n"
    i += 1
  end
  output_text += "\n"
end
if number_crossrefs.positive? && opts[:crossrefs]
  output_text += "### Crossrefs\n"
  i = 1
  crossrefs.each do |cc|
    output_text += "[^#{hc[i]}]: #{cc}\n"
    i += 1
  end
  output_text += "\n"
end
output_text += copyright.to_s if opts[:copyright]

# Then write out text to screen
puts
puts output_text
Clipboard.copy(output_text)
