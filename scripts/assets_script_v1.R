#############################################################################
################### ASSETS CAPSTONE PROJECT #################################
#############################################################################

#script for downloading the data of my capstone project using an API and then obtain two assets to support the project.

#Info about the API of openSNP can be found here:
	#https://github.com/openSNP/snpr/wiki/JSON-API

#set the working directory
setwd("/media/dftortosa/Windows/Users/dftor/Documents/diego_docs/industry/data_incubator/capstone_project")



#################################################################
####################### REQUIRED PACKAGES #######################
#################################################################

require(rjson) #for connecting with the API
require(gsubfn) #for converting feet/inches to cm
require(plyr) #for apply functions across lists and data.frames. This is better than apply, because split rows of a data.frame without converting into matrix or array. In that way you can use "$" to call columns. In addition, you can save the output as a data frame or a list.
require(dplyr) #for using the function "bind_rows", which binds the data.frames of a list by rows
require(data.table) #for using fread to fast upload of tables
require(SNPassoc) #for genetic associations
require(rentrez) #for getting the position of each SNP



###########################################################
####################### HEIGHT DATA #######################
###########################################################

#get a list with all phenotypes
list_phenotypes = fromJSON(file="http://opensnp.org/phenotypes.json")
	#https://stackoverflow.com/questions/2617600/importing-data-from-a-json-file-into-r

#select the entry corresponding with height
height_info = list_phenotypes[which(sapply(list_phenotypes, "[[", 2) %in% "Height")]
	#I use sapply for extracting the second elements of each entry of the list, which is the phenotype name
	#IMPORTANT:
		#For the final analysis, we should look for phenotype names having height misspelled, using grepl for that.

#extract the id of height
height_id = height_info[[1]]$id

#load the data of height
json_height <- fromJSON(file=paste("https://opensnp.org/phenotypes/json/variations/", height_id, ".json", sep=""))
str(json_height)

#take a look to the known values of height
json_height$known_variations 
	#there problematic cases I will have to deal with like >200, average, and mixed units (cm, inches....).


##create a data.frame with this data

#extract the id for all individuals with height data
users_ids_height = as.vector(unlist(sapply(json_height$users, "[", 1)))
#check
length(users_ids_height) == length(json_height$users)

#extract the value of height of all individuals
users_value_height = as.vector(unlist(sapply(json_height$users, "[", 2)))
#check
length(users_value_height) == length(json_height$users)

#bind both variables in a data.frame
height_data = cbind.data.frame(users_ids_height, users_value_height)
str(height_data) #we can directly bind them because they come from the save file, so they have the same row order

#modify the id variable
height_data$users_ids_height = paste("user_id_", height_data$users_ids_height, sep="")


##filter the height values
#see a summary of the different height values
table(height_data$users_value_height) #we have cm, averages, parentheses, inches...

#we are going to select only height value in inches and feet for the exploratory analysis because these values are cleaner than values in cm
height_data = height_data[which(grepl('"', height_data$users_value_height) | grepl("'", height_data$users_value_height)),] #select those rows for which height contains " or '

#remove remaining problematic cases
height_data = height_data[-which(grepl("cm", height_data$users_value_height) | grepl("`", height_data$users_value_height) | grepl("know", height_data$users_value_height) | grepl("max", height_data$users_value_height) | grepl("family", height_data$users_value_height) | grepl("/", height_data$users_value_height)),]
	#remove those cases with cm, and added text...

#see the final number of cases
nrow(height_data)

#remove spaces within each measurement
height_data$users_value_height = gsub(" ", "", height_data$users_value_height, fixed=TRUE)
	#gsub replace a string that match a pattern by other string. 
	#Fixed=TRUE means that the pattern is a string to be matched as is, not a regular expression.

#change those cases for which the inches are indicated as '' instead of "
height_data$users_value_height = gsub("''", '"', height_data$users_value_height, fixed=TRUE)

##convert feet/inches to cm
#make the conversion
height_data$users_value_height_clean = as.numeric(gsubfn("(\\d)'(\\d+)", ~ as.numeric(x) * 30.48 + as.numeric(y) * 2.54, sub('"', '', height_data$users_value_height)))
	#gsubfn replace a string that match a pattern but the replacement is not another string but the result of applying the initial string to a function. In this case, we replace the feet (d') and inches (d+) by the corresponding conversion to cm, i.e., after multiplying by the conversion factor.
	#here we use fixed=FALSE because we are using a regular expression.
	#the input is the height value but removing the " of the inches
	#https://stackoverflow.com/questions/55244198/convert-character-vector-of-height-in-inches-to-cm

#see the cases for which height was not calculated
height_data[which(is.na(height_data$users_value_height_clean)),]$users_value_height
	#most errors due to cases with zero inches

#calculate the height in cm for NA cases caused due 0 inches
height_data[which(is.na(height_data$users_value_height_clean)),]$users_value_height_clean = as.numeric(gsubfn("(\\d)'", ~ as.numeric(x) * 30.48, sub('"', '', height_data[which(is.na(height_data$users_value_height_clean)),]$users_value_height)))

#few cases still with NA
height_data[which(is.na(height_data$users_value_height_clean)),]
	#to be solved in the future
	#in the future also take a look cases with the second number (inches) indicated as ' instead of ". For example, 5'0' is converted to 152.4 cm, that is, our script assume that the second number are inches although is indicated with '.

#see the distribution of the data
summary(height_data$users_value_height_clean)
plot(density(na.omit(height_data$users_value_height_clean)))
dev.off()

#remove outlier, height of 64 cm does not sound right
height_data = height_data[which(height_data$users_value_height_clean != min(na.omit(height_data$users_value_height_clean))),]

#check again
summary(height_data$users_value_height_clean)

#plot
height_to_plot = na.omit(height_data$users_value_height_clean)
jpeg("/media/dftortosa/Windows/Users/dftor/Documents/diego_docs/industry/data_incubator/capstone_project/results/prelim_results/height_density_plot.jpeg", width = 880, height = 880)
plot(density(height_to_plot), xlab=paste("Users height in cm (n = ", length(height_to_plot), ")", sep=""), ylab="Frequency", main="Density plot of height", cex.lab=1.5, cex.main=1.5) 
	#height between 142 and 200 cm with a mean and median around 170 cm. Only one case is above 200 cm.
	#close to normal distribution
dev.off()



###########################################################
####################### GENOTYPE DATA #####################
###########################################################

#load the list of all users in openSNP
json_users <- fromJSON(file="http://opensnp.org/users.json")
	#https://stackoverflow.com/questions/2617600/importing-data-from-a-json-file-into-r
str(json_users)

#extract the id of all users
users_ids_all = as.numeric(sapply(json_users, "[", 2))
#check
length(users_ids_all) == length(json_users)


##check that we have to use the id in json_users, not the second one, which belongs to the genotype. Check with one user: 

#We select the user with id = 10635. You can see the profile in the webpage an how the user name matches.
json_users[which(users_ids_all == 10635)]
	#URL for genotype in both cases: https://opensnp.org/data/10635.ancestry.8887
	#https://opensnp.org/users/10635
#According to the profile, the user has a height of 5'4", which is exactly the height associated with that ID in our height data.frame
height_data[which(height_data$users_ids_height == "user_id_10635"),]

#another example with the user 10348. You can see the profile in the webpage an how the user name matches.
json_users[which(users_ids_all == 10348)]
	#URL for genotype in both cases: https://opensnp.org/data/10348.23andme.8605
	#https://opensnp.org/users/10348
#According to the profile, the user has a height of 6'3", which is exactly the height associated with that ID in our height data.frame
height_data[which(height_data$users_ids_height == "user_id_10348"),]

#Therefore, we are correctly using the first ID in "json_users" as the user ID. I guess, the same user can have several genotypes? no problem because below we check for duplicates in user and genotype ID


##prepare a vector with the URL of genotypes of those users with height data
#select the index of the IDs of those users for which we have height data in cm cleaned
index_ids_height = which(paste("user_id_", users_ids_all, sep="") %in% height_data$users_ids_height)

#from each of the users with height data, extract 
#the user ID
users_id_height = sapply(json_users[index_ids_height], "[[", 2)
#all the information about the genotype
users_geno_height = sapply(json_users[index_ids_height], "[[", 3)

#from these variables, select only those users that the genotype data is not empty
users_id_height = users_id_height[which(sapply(users_geno_height, length) != 0)]
users_geno_height = users_geno_height[which(sapply(users_geno_height, length) != 0)]

#from the genotype info of each user, extract
#the ID of the GENOTYPE, NOT the USER
users_geno_id_height = unlist(sapply(sapply(sapply(users_geno_height, "[", 1), '[', 1), "[[", 1))
#the type of genotype data
users_geno_filetype_height = unlist(sapply(sapply(sapply(users_geno_height, "[", 1), '[', 2), "[[", 1))
#the URL for downloading the genotype data
users_geno_url_height = unlist(sapply(sapply(sapply(users_geno_height, "[", 1), '[', 3), "[[", 1))

#bind them all
users_geno = cbind.data.frame(users_id_height, users_geno_id_height, users_geno_filetype_height, users_geno_url_height)

#change the codification of the ID variables
users_geno$users_id_height = paste("user_id_", users_geno$users_id_height, sep="")
users_geno$users_geno_id_height = paste("geno_id_", users_geno$users_geno_id_height, sep="")

#take a look
str(users_geno)
head(users_geno)
summary(users_geno)

#check for duplicates in IDs
!TRUE %in% duplicated(users_geno$users_id_height)
!TRUE %in% duplicated(users_geno$users_geno_id_height)

#create a new variable of IDs
users_geno$user_id_geno_id = interaction(users_geno$users_id_height, users_geno$users_geno_id_height, sep="_")

#check if you lose individuals with height due to lack of genotype data
nrow(height_data) - nrow(users_geno) #we lose 87 individuals with height but with not genotype data


##clean the genotype files based on the file type
#see all types of genotypes
table(users_geno$users_geno_filetype_height) #most cases are from 23andMe

#select only those individuals with geno data from 23andMe
users_geno = users_geno[which(users_geno$users_geno_filetype_height == "23andme"),]
	#We will use only one file type for the exploratory analysis. For the full analyses, I will have to create a pipeline to upload and merge different genotype file types.

#final number of genotypes
nrow(users_geno) #521


## download all genotypes
#first create a folder to save them
system("rm -r data/raw_geno_inv; mkdir data/raw_geno_inv")

#write the function to download
#for debugging
#users_geno_info = users_geno[1,]
geno_down = function(users_geno_info){

	#extract the user ID and URL
	selected_user_id_geno_id = users_geno_info$user_id_geno_id
	selected_url = users_geno_info$users_geno_url_height

	#if the url is not NULL
	if(!is.null(selected_url)){

		#download the file with wget and then compress
		system(paste("cd data/raw_geno_inv/; wget -O ", selected_user_id_geno_id, " ", selected_url, "&& gzip -f ", selected_user_id_geno_id, sep=""))
			#&& means that gzip will be only executed if wget finishes successfully
				#https://www.linuxquestions.org/questions/programming-9/wget-and-gunzip-657400/
			#-f force overwrite of output file

		#result
		download = TRUE
	} else {

		#result
		download = FALSE
	}

	#bind them all
	return(cbind.data.frame(selected_user_id_geno_id, selected_url, download))
}

#run the function with ddply
results_download = ddply(.data=users_geno, .variables="users_id_height", .fun=geno_down, .inform=TRUE, .parallel=FALSE, .paropts=NULL)
	#".inform=TRUE" generates and shows the errors. This increases the computation time, BUT is very useful to detect problems in your analyses.
	#".parallel" to paralelize with foreach. 
	#".paropts" is used to indicate additional arguments in for each, specially interesting for using the .export and .packages arguments to supply them so that all cluster nodes have the correct environment set up for computing. 

#all download
!FALSE %in% results_download$download
system("cd data/raw_geno_inv/; ls -l *.gz | wc -l", intern=TRUE) == nrow(users_geno)
	#intern=TRUE to capture the output as a vector in R
	#list all the files ending with .gz and count

#remove corrupt files
#system("cd data/raw_geno_inv/; rm user_id_10195_geno_id_8459.gz")
	#we should find a way to automatically detect these files and remove them


##bind all the genotypes into one data.frame
#get the name of the genotype files
geno_files_names = list.files("data/raw_geno_inv", pattern=".gz", full.names=FALSE)
geno_files_names = sapply(strsplit(as.character(geno_files_names), split=".gz"), "[", 1)

#get the path of these files
geno_files_paths = list.files("data/raw_geno_inv", pattern=".gz", full.names=TRUE)
#name each path with the name of the corresponding file
names(geno_files_paths) = sapply(strsplit(geno_files_paths, split="/|.gz"), "[", 3)

#check the order
!FALSE %in% c(names(geno_files_paths) == geno_files_names)
	#from each complete path, if we extract the file name (without .gz), we get the same file name than showed in geno_files_names?

#read all the tables (only rs number and genotype) and save into a list
#create a function to be run with lapply
#debugging: x=geno_files_paths[16]
load_genotypes_list = function(x){
	
	#select the path of genotype file
	selected_path = x

	#extract the user and genotype IDs
	selected_ids = strsplit(selected_path, split="/|.gz")[[1]][3]

	#open a vector with error equal to false
	error_occured = FALSE
	warning_occured = FALSE

	#try to catch an error loading the data.frame and save in an_error_occured
	tryCatch( {attempt_loading = fread(selected_path, sep="\t", header=TRUE, colClasses=c(NA, "NULL", "NULL", NA))}, error = function(e) {error_occured <<- TRUE}, warning = function(e) {warning_occured <<- TRUE})
		#tryCatch
			#https://cran.r-project.org/web/packages/tryCatchLog/vignettes/tryCatchLog-intro.html
			#<<- seems to overwrite the content of the saving vector
		#fread
			#read with fread, which is faster than read.table
			#https://stackoverflow.com/questions/1727772/quickly-reading-very-large-tables-as-dataframes/15058684#15058684

	#if no error or warning ocurred save the table
	if(error_occured==FALSE & warning_occured==FALSE){

		#set the column names of the load data.frame: The first is the rs_number and the second is the name of the [[i]] element of the list, i.e., the user and geno IDs
		colnames(attempt_loading) = c("rs_number", selected_ids)

		#save
		return(attempt_loading)
	} else { #if not

		#if error occurred
		if(error_occured == TRUE){
			
			#save error
			return("error")
		} else {

			#save warning
			return("warning")
		}
	}
}
#run
list_data_frames_geno_files = lapply(geno_files_paths, load_genotypes_list)

#check length
length(list_data_frames_geno_files) == length(geno_files_paths)

#check names
!FALSE %in% c(names(list_data_frames_geno_files) == geno_files_names)
	#lapply maintain the names of the elements used as input. In our case, these are the user and genotype IDs saved in geno_files_paths

#check that the second column in each element of the list is equal to the name of that element in the list
second_col_names_check = as.character(sapply(lapply(list_data_frames_geno_files, colnames), "[", 2)) #extract the name of the second column in each element of the list
names_list_check = names(list_data_frames_geno_files) #extract the name of each element of the list
names_list_check[which(second_col_names_check == "NULL")] <- "NULL" #convert to NULL those names belonging to elements with no data.frame loaded
#check
!FALSE %in% c(names_list_check == second_col_names_check)

#remove those elements of the list with no data.frame
list_data_frames_geno_files = list_data_frames_geno_files[which(second_col_names_check != "NULL")]
str(list_data_frames_geno_files)


### merge all the data.frame in the list using the V1 or rs_number ###

#open a folder to save
system("cd data/; rm -rf geno_merged; mkdir geno_merged")


##split the list of data.frames to make the merge in two steps, decreasing the amount of memory used at the same time

#get the middle of the list
middle_list_dfs = round(length(list_data_frames_geno_files)/2)

#select the first and second part of the list
new_list = list()
new_list[[1]] = list_data_frames_geno_files[1:middle_list_dfs]
new_list[[2]] = list_data_frames_geno_files[(middle_list_dfs+1):length(list_data_frames_geno_files)]

#clean
rm(list_data_frames_geno_files)
gc()


##merge all the data.frames in each partition
#vector list names to merge
lists_to_merge = c("first_part_list", "second_part_list")

#open a loop
for(i in 1:length(new_list)){

	#select the [[i]] list
	selected_list = new_list[[i]]

	#merge
	geno_data_raw = Reduce(function(dtf1, dtf2) full_join(dtf1, dtf2, by="rs_number"), selected_list)
		#we want to merge with all=TRUE. We want to maintain those rs numbers present in some individuals, but not in others. In latter steps I will remove rs numbers with low sample size (based on MAF).
			#but merge is too slow, so we are using a faster alternative
		#full join is the equivalent of all=TRUE in merge
			#For ‘full_join()’, all ‘x’ rows, followed by unmatched ‘y’ rows.
			#https://stackoverflow.com/questions/21841146/is-there-an-r-dplyr-method-for-merge-with-all-true
			#https://stackoverflow.com/questions/28250948/how-to-dplyrinner-join-multi-tbls-or-data-frames-in-r
			#https://www.datasciencemadesimple.com/join-in-r-merge-in-r/
	
	#check we have all the users plus the rs_number column
	ncol(geno_data_raw) == (length(selected_list)+1)
	
	#save
	write.table(geno_data_raw, file=gzfile(paste("data/geno_merged/geno_merged_", i, ".txt.gz", sep="")), col.names=TRUE, row.names=FALSE, sep="\t")
	
	#clean both the selected split and the corresponding part of the list. 
	rm(geno_data_raw, selected_list)
		#https://stackoverflow.com/questions/11624885/remove-multiple-objects-with-rm
	new_list[[i]] <- NA
	gc()
		#https://stackoverflow.com/questions/8813753/what-is-the-difference-between-gc-and-rm
}


##merge all partitions

#get the path of all partitions
list_partition_paths = list.files("/media/dftortosa/Windows/Users/dftor/Documents/diego_docs/industry/data_incubator/capstone_project/data/geno_merged", pattern="geno_merged", full.names=TRUE)

#load all of them faster with fread
list_partitions = lapply(list_partition_paths, fread, sep="\t", header=TRUE)

#merge all partitions
geno_data = Reduce(function(dtf1, dtf2) inner_join(dtf1, dtf2, by="rs_number"), list_partitions)
	#IMPORTANT: The first part has 1 million snps, while the second has 10 millions, it is too much for maintaining all the rows. We are going to maintain only shared rows in this preliminary analysis.
	#IMPORTANT: Not sure because the total number of rows is bigger than the smallest of the two partitions...
	#this can be done with inner_join, which is similar to use merge with all=FALSE.
		#For ‘full_join()’, all ‘x’ rows, followed by unmatched ‘y’ rows.
		#https://stackoverflow.com/questions/21841146/is-there-an-r-dplyr-method-for-merge-with-all-true
		#https://stackoverflow.com/questions/28250948/how-to-dplyrinner-join-multi-tbls-or-data-frames-in-r
		#https://www.datasciencemadesimple.com/join-in-r-merge-in-r/


##alternative approach with join_all
#not run
if(FALSE){

	#load
	geno_data = join_all(dfs=list_data_frames_geno_files, by="rs_number", type="full", match="all")
		#dfs is a list of data.frames
		#by is a character vector with the variable name (or names) to join by.
		#type of join: We are using full, as this is equivalent to merge with all=TRUE
			#we want to merge with all=TRUE. We want to maintain those rs numbers present in some individuals, but not in others. In latter steps I will remove rs numbers with low sample size (based on MAF).
				#but merge is too slow, so we are using a faster alternative
			#full join is the equivalent of all=TRUE in merge
				#For ‘full_join()’, all ‘x’ rows, followed by unmatched ‘y’ rows.
				#https://stackoverflow.com/questions/21841146/is-there-an-r-dplyr-method-for-merge-with-all-true
			#https://stackoverflow.com/questions/28250948/how-to-dplyrinner-join-multi-tbls-or-data-frames-in-r
			#https://www.datasciencemadesimple.com/join-in-r-merge-in-r/
		#match: how should duplicate ids be matched? Either match just the ‘"first"’ matching row, or match ‘"all"’ matching rows. Defaults to ‘"all"’ for compatibility with merge, but ‘"first"’ is significantly faster.
			#not really understand this argument but we leave it in a way similar to merge.
	
	#dummy example of join. Just one column to be used to join, which is i, no having the same value for all data.frame. In our case, some individuals have the rs_number, but other rs_numbers are not shared across individuals. Then each of the other columns have different names, just like in our case. Each genotype has its own id.
	if(FALSE){
		x <- data.frame(i = c("a","b","c"), j = 1:3, stringsAsFactors=FALSE)
		y <- data.frame(i = c("b","c","d"), k = 4:6, stringsAsFactors=FALSE)
		z <- data.frame(i = c("c","d","a"), l = 7:9, stringsAsFactors=FALSE)
		dummy_join_1 = join_all(dfs=list(x,y,z), by="i", type="full", match="all")
		dummy_join_2 = join_all(dfs=list(x,y,z), by="i", type="full", match="first")
		dummy_join_3 = Reduce(function(dtf1, dtf2) merge(dtf1, dtf2, by="i", all=TRUE), list(x,y,z))
		identical(dummy_join_1, dummy_join_2)
		identical(dummy_join_1, dummy_join_2)
		identical(dummy_join_2, dummy_join_3)
	}
}

#take a look
str(geno_data)
head(geno_data)
	#the first column is the rsnumber, while the next are the genotypes of all individuals, one column per individual and one row per rs number. 

#get the chromosome numbers and the corresponding rs numbers just one of the files (to decrease file size)
chromo_numbers = fread(geno_files_paths[1], sep="\t", header=TRUE, colClasses=c(NA, NA, "NULL", "NULL"))
colnames(chromo_numbers) = c("rs_number", "chr")
	#if some SNPs are not present here, no  problem because they have to be removed anyways
	#IMPORTANT:
		#I have detected some errors in the chromosome names for sexual chromosomes, for example rs306934 is shown as X, but according to ncbi is in the Y chromosome.

#add the chromosome numbers
geno_data_final = merge(chromo_numbers, geno_data, by="rs_number", all=TRUE)
str(geno_data_final)
head(geno_data_final)
	#again, we need all=TRUE in order to avoid losing rs numbers present in the first individual (used to extract chromosome numbers) and the rest of individuals, and viceversa.

#convert to data.frame
geno_data_final = as.data.frame(geno_data_final)
str(geno_data_final)

#save
fwrite(geno_data_final, file=gzfile(paste("data/geno_merged/geno_data_final.txt.gz", sep="")), col.names=TRUE, row.names=FALSE, sep="\t")
	#geno_data_final = as.data.frame(fread("data/geno_merged/geno_data_final.txt.gz", sep="\t", header=TRUE))



#####################################################################
####################### GENE-HEIGHT ASSOCIATION #####################
#####################################################################

##prepare height data to be modeled with genotype
#extract height data for those individuals included in the final genotype data
col_names_users_raw = colnames(geno_data_final)[which(!colnames(geno_data_final) %in% c("rs_number", "chr"))]
	#get the columns names with all users ID, except the two first, i.e., rs_number and chr
col_names_users = sapply(strsplit(col_names_users_raw, split="_geno_id"), "[", 1)
	#extract only the user ID, not the genotype ID
height_data_users_geno = height_data[which(height_data$users_ids_height %in% col_names_users),]
	#select the corresponding row

#reorder the rows in height data to have the same order than the columns IDs in the genotype data
height_data_users_geno = height_data_users_geno[match(col_names_users, height_data_users_geno$users_ids_height),]

#check order
summary(sapply(strsplit(colnames(geno_data_final)[which(!colnames(geno_data_final) %in% c("rs_number", "chr"))], split="_geno"), "[", 1) == height_data_users_geno$users_ids_height)


##write function to model the association between each SNP and height
#for debugging: selected_row=geno_data_final[1,]; response=height_data_users_geno[, c("users_ids_height", "users_value_height_clean")]
geno_additive_pheno = function(selected_row, response){

	#extract the rs_number and chromosome
	selected_rs = as.vector(selected_row$rs_number)
	selected_chr = as.vector(selected_row$chr)

	#select all the genotypes
	selected_row_geno_data = selected_row[,which(!colnames(selected_row) %in% c("rs_number", "chr"))]

	#prepare a data.frame with genotypes and user IDs
	geno_names = sapply(strsplit(colnames(selected_row_geno_data), split="_geno"), "[", 1) #ids
	geno_values = as.character(selected_row_geno_data) #genotypes
	geno_data_model = cbind.data.frame(geno_names, geno_values) #combine

	#change column names of both height and geno data.frames
	colnames(response)[which(colnames(response) == "users_ids_height")] = "user_ids"
	colnames(geno_data_model)[which(colnames(geno_data_model) == "geno_names")] = "user_ids"

	#merge height and genotype data by ID
	data_model = merge(response, geno_data_model, by="user_ids", all=FALSE)
		#we need IDs with both height and genotype

	#select only those cases with ATCG in order to avoid NAs, "--" and other non-genotypes
	data_model = data_model[which(grepl("A", data_model$geno_values, fixed=TRUE) | grepl("T", data_model$geno_values, fixed=TRUE) | grepl("C", data_model$geno_values, fixed=TRUE) | grepl("G", data_model$geno_values, fixed=TRUE)),]
		#genotypes that include A OR T OR C or G
		#fixed=TRUE because we are not using a regular expression but a fixed string
	data_model$geno_values = droplevels(data_model$geno_values) #remove not used levels

	#if the remainder data.frame has genotypes
	if(nrow(data_model)>1){

		##compute additive genotype variable
		#from the cleaned genotype variable, get all the unique genotypes
		unique_genotypes = as.character(unique(data_model$geno_values))

		#from there, get the two alleles
		first_set_alleles = sapply(strsplit(unique_genotypes, split=""), "[", 1)
		second_set_alleles = sapply(strsplit(unique_genotypes, split=""), "[", 2)
		unique_alleles = unique(na.omit(c(first_set_alleles, second_set_alleles)))

		#calculate the number of individuals with each allele
		allele_count_1 = length(which(grepl(unique_alleles[1], data_model$geno_values)))
		allele_count_2 = length(which(grepl(unique_alleles[2], data_model$geno_values)))

		#define the minor (less frequent) and major (more frequent) alleles
		minor_allele = ifelse(allele_count_1 < allele_count_2, unique_alleles[1], unique_alleles[2])
		major_allele = unique_alleles[which(!unique_alleles %in% minor_allele)]

		#extract the position of each type of genotype, minor and major homozygote and heterzygote
		index_hetero = which(grepl(paste(minor_allele, major_allele, sep=""), data_model$geno_values) | grepl(paste(major_allele, minor_allele, sep=""), data_model$geno_values))
		index_homo_minor = which(grepl(paste(minor_allele, minor_allele, sep=""), data_model$geno_values))
		index_homo_major = which(grepl(paste(major_allele, major_allele, sep=""), data_model$geno_values))
			#IMPORTANT:	
				#CHECK WARNING:
					#1: In grepl(paste(minor_allele, major_allele, sep = ""),  ... :
					#  argument 'pattern' has length > 1 and only the first element will be used

		#open an empty variable for the new additive genotype
		data_model$geno_additive = NA

		#fill the new variable counting the number of copies of the minor allele per genotype
		if(length(index_hetero)>0){
			data_model[index_hetero,]$geno_additive = 1
			check_1 = !FALSE %in% c(unique(data_model[which(data_model$geno_additive == 1),]$geno_values) %in% c(paste(major_allele, minor_allele, sep=""), paste(minor_allele, major_allele, sep="")))
		} else {
			check_1 = NA
		}
		if(length(index_homo_minor)>0){
			data_model[index_homo_minor,]$geno_additive = 2
			check_2 = unique(data_model[which(data_model$geno_additive == 2),]$geno_values) == paste(minor_allele, minor_allele, sep="")
		} else {
			check_2=NA
		}
		if(length(index_homo_major)>0){
			data_model[index_homo_major,]$geno_additive = 0
			check_3 = unique(data_model[which(data_model$geno_additive == 0),]$geno_values) == paste(major_allele, major_allele, sep="")
		} else{
			check_3=NA
		}

		#remove NAs for the new variable and convert to factor
		data_model = data_model[which(!is.na(data_model$geno_additive)),]
		data_model$geno_additive = as.factor(data_model$geno_additive)

		#count the number of individuals with each genotype
		count_genotypes = table(data_model$geno_additive)

		#number genotypes
		number_genotypes = length(count_genotypes)

		#extract the genotype with the smallest sample size
		min_geno_count = min(count_genotypes)
	} else { #if not

		#set the variables as NA (zero for the number of genotypes)
		count_genotypes=NA
		number_genotypes=0
		min_geno_count=NA
		check_1=NA
		check_2=NA
		check_3=NA
	}

	#if the genotype with the smallest sample size has more than 10 individuals and we have more than 1 genotype
	if(min_geno_count>10 & number_genotypes>1){

		#run two linear models
		#one with the genotype as predictor 
		model_1 = glm(users_value_height_clean ~ geno_additive, data=data_model, family=gaussian)
		#other without predictor
		model_2 = glm(users_value_height_clean ~ 1, data=data_model, family=gaussian)
			#IMPORTANT: in the future we will add sex as a control variable
				#you can use the presence of Y in the chromosome column of geno_data_final
				#but note that some Y/X genetic variants could be lost during the merging of the two big genotype datasets, which only maintains rs_numbers included in both datasets, so you should probably do it before that big merging.

       	#extract the pvals                
       	p_value = anova(model_1, model_2, test="Chi")$"Pr(>Chi)"[2]
	} else { #if not

		#we do not model anything
		p_value = NA
	}

	#save the results
	results = cbind.data.frame(selected_chr, selected_rs, min_geno_count, number_genotypes, check_1, check_2, check_3, p_value)

	#return
	return(results)
}

#check that the variable used to separate rows in geno_data_final (rs_number) has no duplicates
length(which(duplicated(geno_data_final$rs_number))) == 0
	#IMPORTANT: We have duplicates in the rs_number, something to CHECK.

#remove duplicates
geno_data_final = geno_data_final[which(!duplicated(geno_data_final$rs_number)),]

#remove cases of non-nuclear chromosomes
geno_data_final = geno_data_final[which(!is.na(geno_data_final$chr) & geno_data_final$chr !="MT"),]
!TRUE %in% c(c(NA, "MT") %in% unique(geno_data_final$chr))

#remove snps with "i" instead of a rs number.
geno_data_final = geno_data_final[which(!grepl("i", geno_data_final$rs_number)),]
	#IMPORTANT
		#I have detected that some of these SNPs have only 1 allele! Only 13280.
		#CHECK

#extract the height data 
response_data = height_data_users_geno[, c("users_ids_height", "users_value_height_clean")]

#run the function with ddply
results_geno_pheno = ddply(.data=geno_data_final, .variables="rs_number", .fun=geno_additive_pheno, response=response_data, .inform=TRUE, .parallel=FALSE, .paropts=NULL)
	#after .fun, you can add additional arguments to be passed to the function
	#".inform=TRUE" generates and shows the errors. This increases the computation time, BUT is very useful to detect problems in your analyses.
	#".parallel" to paralelize with foreach. 
	#".paropts" is used to indicate additional arguments in for each, specially interesting for using the .export and .packages arguments to supply them so that all cluster nodes have the correct environment set up for computing.

#take a look
str(results_geno_pheno)
head(results_geno_pheno)
summary(results_geno_pheno)

#checks
nrow(results_geno_pheno) == nrow(geno_data_final) #we have all the rows
all(is.na(results_geno_pheno[which(results_geno_pheno$min_geno_count<10 | is.na(results_geno_pheno$min_geno_count) | results_geno_pheno$number_genotypes < 2),]$p_val)) #all cases without min_geno_count, min count lower than 10 or with less than 2 genotypes
!FALSE %in% c(results_geno_pheno$selected_rs == results_geno_pheno$rs_number)

#see the most significant associations
nominal_significant = results_geno_pheno[which(results_geno_pheno$p_value<0.05),]
head(nominal_significant[order(nominal_significant$p_value, decreasing=FALSE),], 30)
	#IMPORTANT: 
		#There are some FALSE for check_3.
		#Maybe because some SNPs are incomplete and only have one of the two alleles.
		#Only 13 cases within the significant SNPs, not urgent for the preliminary analysis. Note that I have already applied filters of sample size, so the rest of SNPs with TRUE for the checks and included in the models had enough number of valid genotypes.
			#For example, rs75953429, which is analyzed three times. The same p-value is obtained the three times, but it should not be repeated as we only want each rs_number analyzed one time.

#see the distribution of the significant p_values
significant_p_values = na.omit(nominal_significant$p_value)
jpeg("/media/dftortosa/Windows/Users/dftor/Documents/diego_docs/industry/data_incubator/capstone_project/results/prelim_results/signi_results_density_plot.jpeg", width = 880, height = 880)
plot(density(significant_p_values), xlab=paste("P-values (n = ", length(significant_p_values), ")", sep=""), ylab="Frequency", main="P-values of significant height-genes associations", cex.lab=1.5, cex.main=1.5) 
dev.off()

#save
#system("mkdir results/prelim_results")
write.table(results_geno_pheno, file=gzfile(paste("results/prelim_results/prelim_results_geno_pheno.txt.gz", sep="")), col.names=TRUE, row.names=FALSE, sep="\t")
	#results_geno_pheno = as.data.frame(fread("results/prelim_results/prelim_results_geno_pheno.txt.gz", sep="\t", header=TRUE))



#####################################################
################# MANHATAN PLOT #####################
#####################################################

#We are not going to run this for now, given it is not extremely necessary and require considerable computation time.

##get the position of each SNP
if(FALSE){ #run only one time

    #vector with SNPs
    snps_to_search=results_geno_pheno$rs_number
    
    #empty data.frame
    chromo = data.frame(selected_snp=NA, chr_snps=NA, chrpos=NA)
    
    #for each snp 
    for(i in 1:length(snps_to_search)){

        #select [i] snp
        selected_snp = snps_to_search[i]

        #submit a search for this snp in Homo sapiens
        snp_search = entrez_search(db="snp", term=paste(selected_snp, " AND Homo sapiens[Organism]", sep=""), use_history=TRUE) #use_history must be TRUE for extracting the summary

        #Total number of hits for the search
        total_hits = snp_search$count

        #if there is one or more hits
        if(!total_hits == 0){

            #obtain a summary of the search 
            snp_summ <- entrez_summary(db="snp", web_history=snp_search$web_history)    
            #extract the chr, fxn_class and global_maf from the summary as a data.frame
            extract_summ = extract_from_esummary(snp_summ, c("chr", "chrpos"))
            	#In dec 2021, chrpos gets the position of the snp in GRCh38, check for example rs9939609
            		#https://www.ncbi.nlm.nih.gov/snp/?term=rs9939609

            #if there are more than 1 results 
            if(total_hits > 1){

                #extract the rs name of the [i] snp without rs
                snp_name_no_rs = strsplit(selected_snp, split="rs")[[1]][2] #this is the notation used in rentrez

                #extract the result of the rentrez that match with the [i] snp
                match_result = which(colnames(extract_summ) == snp_name_no_rs)

                #subset for that snp
                subset = extract_summ[, match_result]
            } else {
                subset = extract_summ
            }

            #any element of the list is another list empty? Those elements create problem in the conversion into data.frame
            empty_element = as.vector(which(lapply(subset, length) == 0))

            #add NA to that element
            if(length(empty_element) > 0){
                subset[[empty_element]] <- NA
            }                 

            #convert subset into data.frame
            subset = as.data.frame(subset)

            #extract the column of the chromosome and chromosome position
            chr_number_col = which(colnames(subset) %in% c("chr")) #the name change across snps 
            chrpos_number_col = which(colnames(subset) %in% c("chrpos")) #the name change across snps 

            #check that there only one number of chr and save it
            if(length(unique(subset[, chr_number_col])) == 1){
                chr_snps = unique(subset[, chr_number_col])
            } else{
                chr_snps = NA
            }
            
            #check that there only one number of chr and save it
            if(length(unique(subset[, chrpos_number_col])) == 1){
                chrpos = unique(subset[, chrpos_number_col])
            } else{
                chrpos = NA
            }


        } else { #if there is any hit then
            chr_snps = NA
            chrpos=NA
        }
        
        #save it along with the snp name
        chromo = rbind.data.frame(chromo, cbind.data.frame(selected_snp, chr_snps, chrpos))
    }
    
    #remove the first row with NA
    chromo = chromo[-1,]
    
    #check that all snps are included
    nrow(chromo) == length(snps_to_search)
    length(which(chromo$selected_snp %in% snps_to_search)) == length(snps_to_search)

    #change column name of the SNPs to merge
    colnames(chromo)[which(colnames(chromo) == "selected_snp")] = "rs_number"

    #save
    write.table(chromo, file=gzfile(paste("data/geno_merged/chromo_snps.txt.gz", sep="")), col.names=TRUE, row.names=FALSE, sep="\t")

	#load the SNP positions
	chromo = as.data.frame(fread("data/geno_merged/chromo_snps.txt.gz", sep="\t", header=TRUE))
	
	#merge by rs_number
	final_results = merge(chromo, results_geno_pheno, by="rs_number", all.x=FALSE, all.y=TRUE)
		#we maintain all the rs_numbers from the genotype data. This is what we need, we discard those SNPs with position but not result
	
	#check
	!FALSE %in% c(final_results$rs_number == final_results$selected_rs)
}