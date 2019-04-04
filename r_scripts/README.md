r_scripts is an R script for assessing logistic regression models. It gets as input the output result of predictors script (https://github.com/kld2/predictors), more specifically the file named allProjects_AllVariables.csv. This file contains all variables (dependent and independent ones) needed to run statistical analysis based on logistic regression models. To run this script, execute the following instructions (we use Linux, so you have to use the correspondent windows commands to reach the same):

******Install R distribution and used packages
1) You need to install R distribution package, in case it does not become available on your machine: sudo apt-get install r-cran-car.
2) After installing R, make sure whether the following packages "aod" and "car" are installed. Another way, you also need to install those as follows:

     a) install.packages('aod')
     
     b) install.packages('car')
     
     

*******Check for collinearity
1) Since in this study, we evaluate more than one variable in the same model, you need to check the collinearity among these variables, as required when performing regression models. So, if two variables have a strong correlation, they can not be put together in the same model. For instance, if you want to assess variables A, B, and C, you first need to check collinearity among them. Thus, if the correlation between A and C, for instance, is 0.7, then they are strongly correlated. We consider a threshold above 0.59 to state that two variables are strongly correlated. So, you need to choose which variable (in this example, A or C) should be considered to perform a given model, since performing strongly correlated variables in the same model lead to inconsistent outcomes. Back to the example, consider that the variable B has a weak (or even moderate) correlation with both A and C variables. Then you could test two different models: a) one model with variables A and B and b) another model with B and C variables.

So, which variables to choose to assess in a regression model demands a human decision, because it depends on the researcher interest since all variables can be tested based on different combinations, which largely increases depending on the number of variables. Furthermore, models can also be evaluated with only one variable. In this case, no correlation check is needed. 
 
To visualize the correlation between variables, you can use any available correlation matrix analyzer. We suggest the Correlation matrix - online software: Analysis and visualization (http://www.sthda.com/english/rsthda/correlation-matrix.php).

All you need is follow its web page instructions. In a nutshell, you should:
a) Upload the file with the variables: allProjects_AllVariables.csv
b) Then click the 'Analyze' button 
c) Select in the list, only the variables you want to check correlation, which in our study corresponds to the following list:
 - existsCommonSlice               
 - totalCommonSlices  
 - existsCommonPackages             
 - totalCommonPackages  
 - numberOfCommitsGeoAverage         
 - numberOfAuthorsGeoAverage         
  - numberOfChangedFilesGeoAverage  
 - numberOfChangedLinesGeoAverage    
- minimumLifeTimeGeoAverage        
 - contributionConclusionDelay       

 d) select the option "Spearman" in the Correlation Methods field and then click the 'Ok' button.

Then, the correlation matrix is showed with the correlation value in a pair-wise way (you can also export to a file). So, by visualizing the correlation matrix, you can decide how to assemble the variables that will be tested and how many models do you want to test. Finally, you can use our script to asses that, as described below.

*******Run the Logistic Regression Model analyzer
1) Copy the allProjects_AllVariables.csv file to the input folder in this project.

2) Configure the sampleProjectsList.csv with the name of the file in step 1 above. 

OBS: Although in our study we are interested in evaluating the aggregated sample (allProjects_AllVariables.csv), our script can evaluate a list of different samples passed at a once. So you need set the N files, representing the N samples in that file. However, for this study, we are only interested in evaluating the aggregated sample. That is why only the allProjects_AllVariables.csv file should be set in this file.

3) Open the script  r_multipleLogReg_Analysis.R and alter da parameter 'predictorsList' (located in the penultimate line of this file) with the list of variables that will compose the model to be tested. So, considering the example we mentioned before, you should set this parameter as follows: 

- predictorsList <- c("A","B"), if you want to test model a) or 

- predictorsList <- c("B","C"), if you want to test model b)

To each new model you test, you should edit this parameter accordly

4) Run the main script: Rscript r_multipleLogReg_Analysis.R

5) After that, a folder named MultipleGLM_Results will be automatically created with the outcomes generated in a file named  analysis_output_Multiple_GLM.txt.  For each new model you test, the results will be appended in this file.
