
#!/usr/bin/ruby
###############################################################
#
# CSCI 305 - Ruby Programming Lab
#
# <Henry> <Barker>
# <henrybarker00@gmail.com>
#
###############################################################
#enumerator is user for two functions, each_cons and max_by
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

#this function finds the most common word following an input word
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
		IO.foreach(file_name) do |line| #for each line of the given file
			#cleanup the line to extract the title from the garbage data
			title = cleanup_title(line)
			#if the title is not valid go to the next line
			if(title.eql? "NO MATCH")
				next
			else
				total += 1
			end
			title.downcase!
			#each_cons is from enumerator
			#this line takes in a string, splits it at whitespace into the component words
			#and then uses each_cons to take each group of two words and put them into an array
			text = title.split(' ').each_cons(2).to_a
			#for each pair of words in the string
			text.each do |str|
				#if the first word of each bigram is not in the hash already, put it in the hash
				if !$bigrams.has_key?(str[0])
					$bigrams[str[0]] = Hash.new
				end
			end
			#for each pair of words
			text.each do |bigram|
				#filter out common cyclic words to reduce repetition
				if(bigram[1] =~ /^(a|an|and|by|for|from|in|of|on|or|out|the|to|with)$/)
					next
				#if the bigram has the second word already in the second hash, add 1 to the value
				elsif($bigrams[bigram[0]].has_key?(bigram[1]))
				  $bigrams[bigram[0]][bigram[1]] = $bigrams[bigram[0]][bigram[1]]+1
				#if this is the first occurance of a following word, set its value to 1
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

#this function creates a determinisic title based on a seed word
def create_title(seed)
	#this list will be used for eliminiating repetition from the generated titles
	title_list = []
	count = 1
	temp = seed
	title_list[0] = seed
	#create the beginning of the final title if the word exists in the bigrams
	if($bigrams.has_key?(seed))
		final = seed
	#if the word does not exist, return an empty string as the title
	else
		return ""
	end
	#until the most common following word has already appeared in the title
	#find the most common following word and add it to the new title, then repeat
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
	#return the final string
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
		#need to use $stdin.gets here because thanks to the idiosyncracies of Ruby,
		#because we opened a file earlier, gets is automatically set to read from the file
		#despite doing all the IO in a seperate function
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
