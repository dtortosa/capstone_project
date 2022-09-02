# **Prediction of EUR/USD exchange rate**

This repository includes analyses about my data science capstone project. The goal of this project is to improve the predictions of EUR/USD exchange rate using Twitter sentiment around these currencies.

## Introduction

The prediction of currencies is relevant for minimizing losses due to currency fluctuations. In this regard, the Euro is the ([second most important currency worldwide](https://www.statista.com/statistics/247362/global-foreign-exchange-market-turnover-by-currency/)), thus being its prediction relevant for many economic agents. 

The Euro is [fiat money](https://en.wikipedia.org/wiki/Fiat_money), being a financial asset instead of a real asset. Therefore, it is the financial liability or debt that the European Central Bank (BCE) acquires with the holder of the Euro currency. The value of this financial asset depends on the expected services that this asset can give in the future. What expect Euro holders from the Euro? They hold Euros because this currency is backed by the European Central Bank (ECB) so they expect it will be be more or less stable. If for any reason, the demand of Euros decreases, the ECB can sell its to buy Euros, decreasing the amount of Euros in circulation and stabilizing its value. In addition, European Union countries with their balance can influence in the amount of Euros in the market. If these countries are spending less than they gain (i.e., profits in form of taxes are higher than the Goverments's spending), they will act as a sink of Euros, decreasing even more the amount of Euros in circulation. In contrast, many European countries in deficit would mean more Euros in circulation. 

All of this supports that the expectations of the economic agents around, not only the actions of the ECB, but also around the economy of European countries, can influence the value of the Euro. I have used Twitter to collect echoes of these previous expectations and improve the predictions of EUR/USD exchange rate. This will be relevant for someone trying to predict fiat currencies in general and in particular the Euro in order to get more beneficial exchanges in the short term. Therefore, the approach I have developed here can be included in existing pipelines dedicated to predict the value of fiat currencies.

## Approach

### Data collection and processing

#### EUR/USD exchange rate

I have obtained the EUR/USD exchange rate from the webpage of the [European Central Bank](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/eurofxref-graph-usd.en.html).

These steps can be found with detailed explanations in [`01_data_preparation_eur_pricing.ipynb`](/scripts/01_data_preparation_eur_pricing.ipynb)

## Results
