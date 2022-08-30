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
cd data/json_files
snscrape --jsonl --progress --since 1999-1-1 twitter-search "european central bank until:2022-08-25" > search_euro_bank_twitter_1999_1_1.json
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
snscrape --jsonl --progress --since 1999-1-1 twitter-hashtag "ecb until:2022-08-25" > hashtag_euro_bank_twitter_1999_1_1.json

snscrape --jsonl --progress --since 1999-1-1 twitter-search "EU debt crisis until:2022-08-25" > search_eu_debt_crisis_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "european union economy until:2022-08-25" > search_european_union_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Iceland economy until:2022-08-25" > search_iceland_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Portugal economy until:2022-08-25" > search_portugal_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Italy economy until:2022-08-25" > search_italy_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Ireland economy until:2022-08-25" > search_ireland_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Greece economy until:2022-08-25" > search_greece_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Spain economy until:2022-08-25" > search_spain_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Cyprus economy until:2022-08-25" > search_cyprus_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Slovenia economy until:2022-08-25" > search_slovenia_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "France economy until:2022-08-25" > search_france_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Belgium economy until:2022-08-25" > search_belgium_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Croatia economy until:2022-08-25" > search_croatia_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Germany economy until:2022-08-25" > search_germany_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Netherlands economy until:2022-08-25" > search_netherlands_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Finland economy until:2022-08-25" > search_finland_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Austria economy until:2022-08-25" > search_austria_economy_twitter_1999_1_1.json

snscrape --jsonl --progress --since 1999-1-1 twitter-search "Luxembourg economy until:2022-08-25" > search_luxembourg_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Slovakia economy until:2022-08-25" > search_slovakia_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Malta economy until:2022-08-25" > search_malta_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Estonia economy until:2022-08-25" > search_estonia_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Latvia economy until:2022-08-25" > search_latvia_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Lithuania economy until:2022-08-25" > search_lithuania_economy_twitter_1999_1_1.json


snscrape --jsonl --progress --since 2003-11-1 twitter-search "Jean-Claude Trichet until:2011-10-31" > search_trichet_twitter.json
snscrape --jsonl --progress --since 2011-06-24 twitter-hashtag "Draghi until:2019-10-31" > hashtag_draghi_twitter.json
	#starting when Draghi was finally selected as president.
snscrape --jsonl --progress --since 2019-09-17 twitter-hashtag "Lagarde until:2022-08-25" > hashtag_lagarde_twitter.json
	#starting when Lagarde was finally selected as president.
#The searches for tweets about Draghi and Lagarde do not work, so I looked for hashtags instead.



snscrape --jsonl --progress --since 1999-1-1 twitter-search "Federal Reserve until:2022-08-25" > search_fed_twitter_1999_1_1.json
	#stopped early
snscrape --jsonl --progress --since 1999-1-1 twitter-hashtag "fed until:2022-08-25" > hashtag_fed_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "US economy until:2022-08-25" > search_us_economy_twitter_1999_1_1.json
	#stopped early
snscrape --jsonl --progress --since 2006-2-1 twitter-search "Ben S. Bernanke until:2014-01-31" > search_bernanke_twitter_1999_1_1.json
snscrape --jsonl --progress --since 2014-2-1 twitter-search "Janet L. Yellen until:2018-01-31" > search_yellen_twitter_1999_1_1.json
snscrape --jsonl --progress --since 2018-2-1 twitter-search "Jerome H. Powell until:2022-08-25" > search_powell_twitter_1999_1_1.json

