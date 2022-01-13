# Assets generated during the preliminary analyses

I have performed a preliminary processing of the data and analyses for my capstone project. The whole script used for that can be found [here](https://github.com/dtortosa/capstone_project/blob/f4b446cda1417e4c871ad62baf4865bedb6ced77/scripts/assets_script_v1.R).


## First asset

Density plot showing the density distribution of height of openSNP users for which I could get genotype data from the API. Height shows a distribution resembling a normal distribution. It ranges from 142.24 to 203.20 cm with a median around 170.18 cm. Only one case is above 200 cm.

![](/results/prelim_results/height_density_plot.jpeg)


## Second asset

For this density plot, I selected only those genotype-height associations with a p-value lower than 0.05, totaling to 9134 associations. The distribution show the presence of both just marginally significant and more significant p-values, both will be used for the proposed polygenic score to predict height.

![](/results/prelim_results/signi_results_density_plot.jpeg)
