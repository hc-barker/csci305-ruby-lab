
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
def cleanup_title line
	#matches anything after > and before the end of the line
	#this will always be after the last <SEP>
	line =~ /[^>]+$/mi
	#get rid of feat. and anything after the other superfluous seperators
	no_superfluous_title = $&.sub(/(([\(\[{\\\/_\-:"+=*]|(feat\.)).*)/, "")
	#get rid of annoying punctuation
	no_punctuation_title = no_superfluous_title.gsub(/[?¿!¡.;&@%#|]/, "")
	#if the title has non english characters

	if no_punctuation_title =~ /.*[^\w\s'].*/
		return "NO MATCH"
	else
		#if the title is all english downcase it and return
		return no_punctuation_title.downcase.chomp
	end
end

def mcw(string)
	if($bigrams.has_key?(string) != nil) #if the bigram hash has the word
		#look at the secondary hash that contains all the following Words
		#this looks like {following, frequency} so we can use
		#max_by to sort by frequency and return following of the hightest frequency
		return $bigrams[string].max_by{|following,freq| freq}[0]
	else #if the bigram hash does not have the word
		return ''
	end
end
# function to process each line of a file and extract the song titles
def process_file(file_name)
	puts "Processing File.... "
	total = 0
	begin
		IO.foreach(file_name) do |line|
			#puts line
			title = cleanup_title(line)
			if(title.eql? "NO MATCH")
				next
			else
				total += 1
			end
			title.downcase!
			text = title.split(' ').each_cons(2).to_a
			#puts text.inspect
			text.each do |str|
				if !$bigrams.has_key?(str[0])
					$bigrams[str[0]] = Hash.new
				end
			end
			text.each do |bigram|
				if(bigram[1] =~ /^(a|an|and|by|for|from|in|of|on|or|out|the|to|with)$/)
					next
				elsif($bigrams[bigram[0]].has_key?(bigram[1]))
				  $bigrams[bigram[0]][bigram[1]] = $bigrams[bigram[0]][bigram[1]]+1
				else
					$bigrams[bigram[0]][bigram[1]] = 1
				end
			end
		end
		puts "Total tracks: #{total}"

		puts "Finished. Bigram model built.\n"
	rescue
		STDERR.puts "Could not open file"
		exit 4
	end
end

def create_title(seed)
	title_list = []
	count = 1
	temp = seed
	title_list[0] = seed
	if($bigrams.has_key?(seed))
		final = seed
	else
		return ""
	end
	while(title_list.include?(mcw(temp)))
		if($bigrams.has_key?(mcw(temp)))
			final = final + " " + mcw(temp)
			title_list[count] = mcw(temp)
			count = count + 1
		else
			return final
		end
		temp = mcw(temp)
	end
	return final
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
	running = true
	prompt = "Enter a word [Enter 'q' to quit]"
	fancy_prompter = "> "
	while(running)
		puts "Enter a word [Enter 'q' to quit]"
		puts fancy_prompter
		while(input = $stdin.gets.chomp.downcase)
			case input
			when 'q'
				puts "Thanks for making music"
				running = false
				break
			else
				puts create_title(input)
			end
		end
	end
end

if __FILE__==$0
	main_loop()
end
