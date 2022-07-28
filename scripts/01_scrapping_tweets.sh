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
snscrape --jsonl --progress --since 1999-1-1 twitter-search "european central bank until:2022-07-17" > search_euro_bank_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-hashtag "ecb until:2022-07-17" > hashtag_euro_bank_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "EU debt crisis until:2022-07-17" > search_eu_debt_crisis_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "european union economy until:2022-07-17" > search_european_union_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Iceland economy until:2022-07-17" > search_iceland_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Portugal economy until:2022-07-17" > search_portugal_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Italy economy until:2022-07-17" > search_italy_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Ireland economy until:2022-07-17" > search_ireland_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Greece economy until:2022-07-17" > search_greece_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Spain economy until:2022-07-17" > search_spain_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Cyprus economy until:2022-07-17" > search_cyprus_economy_twitter_1999_1_1.json
snscrape --jsonl --progress --since 1999-1-1 twitter-search "Slovenia economy until:2022-07-17" > search_slovenia_economy_twitter_1999_1_1.json


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

#if you remember, my goal is to use sentiment analysis to improve the prediction of the euro currency.

#I have found a tool to download tweets from twitter without restriction about amount of data or time window, I can do searches with sentences or look for hashtags. It is great, until now, I have download 6 gigabytes of tweets, a few million of tweets. This includes tweets about the european central bank, europe's economy, and economy of specific countries like spain or greece. The tool works really good and can download hundred thousands of tweets in a few hours. 

#Now I want to define better what sentiment variables I want to create
	#one simple option is just do a sentiment analysis with all tweets about the european central bank and see if this improve predictions.
	#I have also think that I can do mutliple sentiment analyses, one aroung the economy of greece, another about the eocnomy of germany, spain... and then combine all the sentiments into one single variable using a PCA or something like that.
	#I can also do a negative variable, for exmaple the sentiment around the search europe debt crisis. Of course, anything aobut this will be negative, so the options would be less negative or more negative.
	#at the end, maybe i could have a multivariate model that consider different aspects of the sentiment arount Europe´s economy. 

#any feedback or idea about this is very welcome. 
	#put all of them in the model, avodid ovferrinf, keep important featuer and see what happens, you do not care about feature importance.
	#simple model
		#if you find something interestnig, then you can go to ARIMA, that consider shocks in the data and what happens next.

#also I have detected that there are tweets not related to economy or just repeated because several tweets share the same link from a newspaper or webpage, so maybe I should have to do a filter?
	#hesitant to do extrcit filtering, if someting is repeated maybe a lot of people tlaking, more dirty data baetas clean
	#if you can remove obvious things, do it, but if not, do not it
    #IF YOU BIND TWO SEARCH, REMOVE TWEETS WITH THE SAME ID?

#median per day?
	#averaging operation can reduce impact of trash in the tweets
	#calculate the mean, the median, the SD, the snetime of the last week, month, all these can be features of your model. 


#start with just one topic, median and mean maybe in the same model, simple regression model, changeing time scale improve? try another..., then try other search...
	#do not worry too much about the features, just add them, avoid overffitng with the tools you have and see what happens, this is not statistics...


#OTHER WORDS?
	#eur is to general
	#eu debt crisis is very negative, if there is no crisis, there is no tweets about this,problem? the variable would be negative or zero?

#twitter was funded in 2006...

#combine the two searches of ecb?

#think about getting median or mean per day?

#after summarizing, combine different predictors with PCA or similar?
	#PCA economy european countries?

#temporal series looks if predictors predict coin value in the next data point?

#see what happened in the what ever it takes of Draghi?

#overlap in the two ecb searches?
	#remove repeated tweets using the tweet url?

#tweets not related to economy in my search?

#july 26th capstone selection
#august 10th and 11th are the capstone project.
#meetins everyother week after the thursday session.

#imputation can be used when you have many data of the feature, or maybe you can model the feature using the other features! yes, you are inventnig data, but int datasciente, you want a good performance. scipy has a simple imputer transformer.

#Digital currency forecasting with chaotic meta-heuristic bio-inspired signal processing techniques
#Forecasting cryptocurrency price using convolutional neural networks with weighted and attentive memory channels

