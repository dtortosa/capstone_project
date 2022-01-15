# Assets generated during the preliminary analyses

I have performed a preliminary analysis for my capstone project. The whole script used for that can be found [here](/scripts/assets_script_v1.R).


## Height data
	
- I obtained the available data for the variable "Height" in openSNP using its [API](https://github.com/openSNP/snpr/wiki/JSON-API). I saved the height and ID of each user. 

- Given that the height was in different units and formats, I selected one format just for the preliminary analysis. I selected height data in feet, which was more uniform. In the final analyses, I will process all types of height data. 

- I converted feet to cm and obtained the distribution of the resulting variable. The plot below shows the density distribution of height, which resembles a normal distribution. It ranges from 142.24 to 203.20 cm with a median around 170.18 cm. Only one case is above 200 cm.

![](/results/prelim_results/height_density_plot.jpeg)


## Genotype data and associations with height

- For the genotype data, I also used the [API](https://github.com/openSNP/snpr/wiki/JSON-API) of openSNP. I selected those users for which I got height data in the previous step. Then, I made an additional filter, selecting only those users with genotype data coming from 23andMe. Again, this was done to have more uniform data, but in the final analyses I will make a script flexible enough to handle genotype data from different genetic-testing companies.

- I got a file with hundreds of thousands of genetic variants (single nucleotide polymorphisms or SNPs) for each user. I merged the genetic variants across all users into one single data frame. This included 614,518 genetic variants for 486 users. Then, I selected the height data of these individuals with 23andMe genotype data. In summary, I got height and the genotype of hundred of thousands of variants for each individual. 

- Using this data, I tested the association between height and genetic variants. I run linear models in order to predict height as a function of one genetic variant each time. Then, I compared this model with a null model without the variant, using a likelihood ratio test to calculate a p-value. Therefore, I obtained a p-value for the association between each genetic variant and height.

- I then selected those genotype-height associations with a p-value lower than 0.05, totaling to 9134. The plot below shows the presence of both marginally significant and more significant p-values, which will be all used for the proposed approach. These results support the potential of this dataset to model height as a function of multiple gene variants and develop novel approaches for improving the genetic prediction of human traits.

![](/results/prelim_results/signi_results_density_plot.jpeg)