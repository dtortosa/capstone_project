# **Prediction of EUR/USD exchange rate**

This repository includes analyses about my data science capstone project. The goal of this project is to improve the predictions of EUR/USD exchange rate using Twitter sentiment around these currencies.

## Introduction

The prediction of currencies is relevant for minimizing losses due to currency fluctuations. In this regard, the Euro is the ([second most important currency worldwide](https://www.statista.com/statistics/247362/global-foreign-exchange-market-turnover-by-currency/)), thus being its prediction relevant for many economic agents. 

The Euro is [fiat money](https://en.wikipedia.org/wiki/Fiat_money), being a financial asset instead of a real asset. Therefore, it is the financial liability or debt that the European Central Bank (BCE) acquires with the holder of the Euro currency. The value of this financial asset depends on the expected services that this asset can give in the future. What expect Euro holders from the Euro? They hold Euros because this currency is backed by the European Central Bank (ECB) so they expect it will be be more or less stable. If for any reason, the demand of Euros decreases, the ECB can sell its to buy Euros, decreasing the amount of Euros in circulation and stabilizing its value. In addition, European Union countries with their balance can influence in the amount of Euros in the market. If these countries are spending less than they gain (i.e., profits in form of taxes are higher than the Goverments's spending), they will act as a sink of Euros, decreasing even more the amount of Euros in circulation. In contrast, many European countries in deficit would mean more Euros in circulation. 

All of this supports that the expectations of the economic agents around, not only the actions of the ECB, but also around the economy of European countries, can influence the value of the Euro. I have used Twitter to collect echoes of these previous expectations and improve the predictions of EUR/USD exchange rate. This will be relevant for someone trying to predict fiat currencies in general and in particular the Euro in order to get more beneficial exchanges in the short term. Therefore, the approach I have developed here can be included in existing pipelines dedicated to predict the value of fiat currencies.

## Project

### Data collection and processing

#### EUR/USD exchange rate

I have obtained the EUR/USD exchange rate from the webpage of the [European Central Bank](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/eurofxref-graph-usd.en.html). In particular, I got exchange rate at the end of the day since the launching of the Euro (1999) until the end of August 2022. The format was XML, so I loaded the XML file into python creating dictionaries for each date. I then obtained tuples with the date and EUR/USD exchange rate in each dictionary, finally converting to Pandas Data Frame. The exchange rate in each day was selected as the response variable or target of this project. 

This dataset was also used to obtain variables that could predict the exchange rate of a given dat using the values of previous days:

- Simply the EUR/USD exchange rate of the previous day.
- The rolling mean of the exchange in windows including the previous 5, 10, 60 and 120 days. For example, the 5-days moving average of July 10th would consider the exchange rate between July 5th and 9th. For July 11th would consider the exchange rate between July 6th and 10th, and so on...
- The exponential moving average which gives more weight to recent observations.

The implementation of these steps along with detailed explanations can be found in the first notebook ([`01_data_preparation_eur_pricing.ipynb`](/scripts/01_data_preparation_eur_pricing.ipynb)).

#### Twitter sentiment around EUR and USD

I obtained tweets about the ECB, its presidents in the last years and economy of European Union countries using the Euro. In this way, I attempted to cover the expectations around key aspects for the value of the Euro as explained in the [Introduction](https://github.com/dtortosa/capstone_project#introduction). I also obtained tweets about the Federal Reserve (i.e., the central bank of the US) in order to get the sentiment around the US dollars, given this currency is the direct competitor of the Euro and its value will influence the EUR/USD exchange rate. This dataset included tweets since 2008 and 2009 for the EUR and USD, respectively. See the second notebook for further details ([`02a_data_preparation_scrapping_tweets.ipynb`](/scripts/02a_data_preparation_scrapping_tweets.ipynb))

I used [SNScrape](https://github.com/JustAnotherArchivist/snscrape) a python program dedicated to download data from social networks like Twitter. Input was obtained in json format and loaded into python as Pandas data frames using a custom function that was parallelized across multiple cores with `multiprocessing` in order to speed up the loading of this data, which totals to **13 GB**. Then, I processed the tweets by removing duplicates (i.e., the exact same tweet found in different searches) and tweets in languages other than English, leading to a total of **3.6 millions of tweets**.

Each of these tweets was then cleaned (removing URLs, "#", etc...) and then its sentiment was calculated using VADER from the python package `vaderSentiment`. This generated a compound sentiment of the tweet considering positive, negative and neutral sentiment. Again, this was parallelized with a custom function in order to reduce the computation time.

I performed additional operations on this data in order to obtain metrics summarizing the sentiment of all tweets per day. For example, the average sentiment of all tweets of a given day, the median, standard deviation, etc... With the purpose of really testing the predictive power of Twitter sentiment I created a function that calculates the mean, median, variance, sd.... of all tweets of a previous day. For example the average sentiment for all tweets 2 days ago. I calculated a total of **20 summary statistics** across the 15 previous days to each day. In order words, for each day, I calculated the average sentiment (and the other 19 metrics) the previous day, then 2 days ago, 3, and so on... Each date was run independently in a different core in order to reduce computation time. Using this approach, I generated a battery of 600 predictors, 300 for the sentiment of tweets about EUR and 300 for tweets about USD. 

More details and the implementation of these steps can found in the third ([`02b_data_preparation_twitter_sentiment_eur.ipynb`](/scripts/02b_data_preparation_twitter_sentiment_eur.ipynb)) and fourth notebooks ([`02c_data_preparation_twitter_sentiment_usd.ipynb`](/scripts/02c_data_preparation_twitter_sentiment_usd.ipynb)) for EUR and USD sentiment, respectively.

### Modeling

The EUR/USD exchange ratio, the EUR predictors and the Twitter sentiment predictors were all merged into one single dataset per date, including complete information for all the variables over the past **9 years**. I used this dataset to model the EUR/USD exchange rate of a given date as a function of the previous EUR pricing and twitter sentiment. 

#### Selection of the regressor

Initially, I run multiple regressors that are recommend for this type of regression problem ([Scikit learn flowchart](https://scikit-learn.org/stable/tutorial/machine_learning_map/index.html)). I used cross validation by randomly splitting the data in multiple train-test sets with ShuffleSplit. Then I used `cross_val_score` to calculate the average R<sup>2</sup> across the test sets. I used models with all predictors, but also models with only EUR-pricing predictos and models with only Twitter sentiment data. This repeated across multiple regressors:

- Lasso
- Elastic-Net
- Ridge
- Supporting Vector Machines
- Random Forest
- Extra Trees 
- Gradient Boost
- Voting Regressor

All these regressors were run with default parameters being extra trees regressors the one showing the highest R<sup>2</sup> in the test sets in general. Therefore, this regressor was used in subsequent analyses.

I performed then a random grid search to find the best combination of hyperparameters. This was done separately for the full model (EUR pricing + Twitter sentiment), EUR-only model and Twitter-only model. The optimized models were used to fit and predict the EUR/USD exchange rate in the whole dataset. Variable importance and observed vs. predicted EUR/USD exchange rate was then visualized. This was compared with the simplest model possible which assumes that the current EUR/USD exchange rate is equal to the exchange rate of the previous.

All these modeling steps along with the corresponding results are shown in the last notebook ([`03_predicting_exchange_rate.ipynb`](/scripts/03_predicting_exchange_rate.ipynb)).

## Results

The simplest model with just the previous EUR pricing and without any modeling approach (i.e., current pricing is the same than the previous day) had a high predictive power (R<sup>2</sup> = 0.9968). This may be explained by the fact that Euro pricing changes but at a slow pace, being the value of the previous day a very good predictor. Indeed, the previous pricing is the most important feature in all the models (see the [last notebook](/scripts/03_predicting_exchange_rate.ipynb) for all plots about feature importance) and, as expected, there is a great correlation between EUR/USD exchange rate and the value of the previous day.

<p align="center">
  <img src="https://github.com/dtortosa/capstone_project/blob/main/results/figures/eur_pricing_vs_previous_day.jpg" />
</p>

When predicting to the test sets, the extra tree regressors showed a very high predictive power having the full model (EUR-pricing + Twitter sentiment) the highest R<sup>2</sup> (R<sup>2</sup> = 0.9966). This suggests that the performance of the Twitter-based models is not caused just by an increase of predictors and overfitting. Note that this predictive power was still below the simplest model. However, the extra tree regressors surpassed the simplest model when fitted to the whole dataset, having again the full model the highest predictive power (R<sup>2</sup> = 0.9993), followed by the Twitter-only model (R<sup>2</sup> = 0.9989) and the EUR-only model (R<sup>2</sup> = 0.9982). It is worth to highlight that adding the Twitter sentiment increased the R<sup>2</sup> in 0.11%, a small increase but still relevant given the already very high predictive power I am using a baseline. In addition, the model considering only the sentiment around EUR and USD in the previous 15 days got a extremely high predictive power.

<p align="center">
  <img src="https://github.com/dtortosa/capstone_project/blob/main/results/figures/eur_predictions_final_models.jpg" />
</p>

These results support the potential of public Twitter sentiment to capture the expectations around the Euro and improve the predictions of EUR/USD exchange rate. It could be also useful to improve the prediction of other fiat currencies, maybe even more for those exhibiting higher instability and thus being less influenced by the value of the previous day. Note that here I found an improved prediction using Twitter sentiment of the previous 15 days, so it may be the case that rapid changes in the expectations around a less stable currency could be detected in twitter anticipating short-term changes in the value of the currency. 

This approach can be included in pre-existing pipelines to predict EUR and other fiat currencies in order to improve prediction performance and increase the probabilities of more beneficial exchange rates. The step-by-step explanations in the different notebooks will make easier the implementation. The different notebooks are ordered following the steps of this project:

1. 1_data_preparation_eur_pricing.ipynb
2. 02a_data_preparation_scrapping_tweets.ipynb
3. 02b_data_preparation_twitter_sentiment_eur.ipynb
4. 02c_data_preparation_twitter_sentiment_usd.ipynb
5. 03_predicting_exchange_rate.ipynb
