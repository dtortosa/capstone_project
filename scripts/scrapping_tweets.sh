#!/bin/bash 
	#to run this script: chmod +x script.sh; ./script.sh
	#!/bin/sh does not work with my terminal en msi of David.
	#if you are using "$" to paste the path of the executable, you do not need to use "./" for running the executable.
	#you can save the output and the errors
		#./scrapping_tweets.sh > scrapping_tweets.out #only output
		#./scrapping_tweets.sh 2> error.out #only error
		#./scrapping_tweets.sh > scrapping_tweets.out 2> error.out #both in different files
		#./scrapping_tweets.sh > scrapping_tweets.out 2>&1 #both in the same file
		#https://www.cyberciti.biz/faq/linux-redirect-error-output-to-file/



################################################
######### SCRIPT FOR SCRAPPING TWEETS ##########
################################################

#I will use snscrape to get tweets related to euro currency



##########################################
######### SNSCRAPE INSTALLATION ##########
##########################################

#in order to get the jsonl argument we need the github version of snscrap
	#https://github.com/JustAnotherArchivist/snscrape/issues/77

#installation command
#pip3.8 install --upgrade git+https://github.com/JustAnotherArchivist/snscrape@master

#snscrape info
	#https://github.com/JustAnotherArchivist/snscrape
	#https://pypi.org/project/snscrape/

#tutorial
	#https://medium.com/dataseries/how-to-scrape-millions-of-tweets-using-snscrape-195ee3594721
	#https://betterprogramming.pub/how-to-scrape-tweets-with-snscrape-90124ed006af


#set working directory
cd /media/dftortosa/Windows/Users/dftor/Documents/diego_docs/industry/data_incubator/capstone_project



####################################
######### DOWNLOAD TWEETS ##########
####################################

#get tweets searching "european central bank"
cd results/json_files
snscrape --jsonl --progress --since 2021-06-19 twitter-search "european central bank until:2022-06-19" > euro_bank_twitter_1_year.json
cd ../..
	#[GLOBAL-OPTIONS]
		#--jsonl: get the output as JSON
		#--progress: show progress on stderr
		#--max-results: return only the first N results
		#--since DATETIME: Only return newer than DATETIME
	#SCRAPER NAME
		#twitter-search
		#twitter-hashtag
		#reddit-search
		#etc...
	#[SCRAPER-OPTIONS]
	#Note that
		#Note that --since is an optional argument you can use, but until: is an operator used inside the twitter-search query. This seems to give me more consistent results than putting both arguments inside the query.
			#https://betterprogramming.pub/how-to-scrape-tweets-with-snscrape-90124ed006af