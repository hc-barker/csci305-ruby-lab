
#!/usr/bin/ruby
###############################################################
#
# CSCI 305 - Ruby Programming Lab
#
# <Henry> <Barker>
# <henrybarker00@gmail.com>
#
###############################################################
require 'enumerator'
$bigrams = Hash.new # The Bigram data structure
$name = "Henry Barker"

def cleanup_title(line)
	title_regex = /[^>]+$/mi
	superfluous_text_regex = /^(?:(?!feat\.)[^\({\['\\\/_\-:"+=*])+/
	punctuation_regex = /[?¿!¡.;&@%#|]+/
	non_english_regex = /[\w'\s]+/
	line =~ title_regex
	$& =~ superfluous_text_regex
	no_punctuation_title = $&.gsub(punctuation_regex,'')
	temp = no_punctuation_title.gsub(non_english_regex, '')
	if(temp.eql? '')
		no_punctuation_title.downcase!
		puts "Title: #{no_punctuation_title}"
		return no_punctuation_title
	else
		puts "NO MATCH"
		return "NO MATCH"
	end
end
# function to process each line of a file and extract the song titles
def bigram(string)
	string.split(' ').each_cons(2).to_a
end
def process_file(file_name)
	puts "Processing File.... "
	total = 0
	begin
		IO.foreach(file_name) do |line|

			if(cleanup_title(line).eql? "NO MATCH")
				next
			else
				total += 1
			end
			title = cleanup_title(line)
			text = bigram(title)
			puts text.inspect

						# do something for each line
		end
		puts "Total tracks: #{total}"

		puts "Finished. Bigram model built.\n"
	rescue
		STDERR.puts "Could not open file"
		exit 4
	end
end

# Executes the program
def main_loop()
	puts "CSCI 305 Ruby Lab submitted by #{$name}"

	if ARGV.length < 1
		puts "You must specify the file name as the argument."
		exit 4
	end

	# process the file
	process_file(ARGV[0])

	# Get user input
end

if __FILE__==$0
	main_loop()
end
