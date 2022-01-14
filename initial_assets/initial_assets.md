# Assets generated during the preliminary analyses

I have performed a preliminary processing and analysis of the data for my capstone project. The whole script used for that can be found [here](https://github.com/dtortosa/capstone_project/blob/f4b446cda1417e4c871ad62baf4865bedb6ced77/scripts/assets_script_v1.R).


## Height data
	
- I obtained the available data for the variable "Height" in openSNP using its API. I saved the height and ID of each user. 

- Given that the height was in different units and formats, I select one format just for the preliminary analysis. I selected height data in feet, which was more uniform. In the final analyses, I will process all types of height data. 

- I converted feet to cm and obtained the distribution of this trait. The plot below shows the density distribution of this trait, resembling a normal distribution. It ranges from 142.24 to 203.20 cm with a median around 170.18 cm. Only one case is above 200 cm.

![](/results/prelim_results/height_density_plot.jpeg)


## Genotype data

- For the genotype data, I also used the API of openSNP. I selected those users for which I got height data in the previous step. Then, I made a previous filter, selecting only those users with genotype data coming from 23andMe, totaling to 520 users. Again, this was done to have more uniform data, but in the final analyses I will make a script flexible enough with genotypes from different companies.

- I got a file with hundreds of thousands of genetic variants (single nucleotide polymorphisms or SNPs) for each user. I merged the genetic variants across all users into one single data frame. This included 614,518 genetic variants for 486 users. Then, I selected the height data of these individuals with 23andMe genotypes.


## Genotype-phenotype association

- For each individual, I obtained a height value and the genotype of hundred of thousands of variants. I run linear models in order to predict height as a function of one genetic variant each time across the panel of 486 users. Then, I compared the linear model including the genetic variant with a null model without the variant, using a likelihood ratio test to calculate a p-value. Therefore, I obtained a p-value for the association between each genetic variant and height.

- I then selected those genotype-height associations with a p-value lower than 0.05, totaling to 9134 associations. The plot below shows the presence of both marginally significant and more significant p-values, which will be used for the proposed approach. This support the potential of this dataset to model height as a function of genotype and apply novel approaches to develop polygenic scores.

![](/results/prelim_results/signi_results_density_plot.jpeg)
