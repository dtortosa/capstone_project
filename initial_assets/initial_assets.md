# Assets generated during the preliminary analyses

I have performed a preliminary processing and analysis of the data for my capstone project. The whole script used for that can be found [here](https://github.com/dtortosa/capstone_project/blob/f4b446cda1417e4c871ad62baf4865bedb6ced77/scripts/assets_script_v1.R).


## Steps followed to obtain the two assets

1. **Height data**
	
- I obtained the available data for the variable "Height" in openSNP using its API. I saved the height and ID of each user. 

- Given that the height was in different units and formats, I select one format just for the preliminary analysis. I selected height data in feet and inches, which was more uniform. Then, I converted the values to cm and obtain the distribution of this trait. The plot below shows the density distribution of this trait, resembling a normal distribution. It ranges from 142.24 to 203.20 cm with a median around 170.18 cm. Only one case is above 200 cm.

![](/results/prelim_results/height_density_plot.jpeg)


## Second asset

For this density plot, I selected only those genotype-height associations with a p-value lower than 0.05, totaling to 9134 associations. The distribution show the presence of both just marginally significant and more significant p-values, both will be used for the proposed polygenic score to predict height.

![](/results/prelim_results/signi_results_density_plot.jpeg)
