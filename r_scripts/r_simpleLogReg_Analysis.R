# set paths
rAnalysisPath = getwd()
#setwd("..")

setwd("input") # csv file variables 
variablesCSVPath = getwd()

pathResults = "SimpleGLM_Results"
dir.create(file.path(rAnalysisPath, pathResults), showWarnings = FALSE)
setwd(file.path(rAnalysisPath, pathResults))
resultsGLMPath = getwd()

resultFile = "analysis_output_GLMByPredictor.txt"


# function to get the project list
readConfigProperties <- function(cofigurationFile){
  setwd(rAnalysisPath)
  projects <- c()
  inputFile <- cofigurationFile
  con  <- file(inputFile, open = "r")
  i<-1
  while (length(oneLine <- readLines(con, n = 1)) > 0) {
    myLine <- unlist((strsplit(oneLine, ",")))
    #  print(myLine)
    projects[i] <- myLine
    i <- i+1
  } 
  close(con)
  return (projects)
}

#==============================================================================
#============================SIMPLE LOGISTIC REGRESSION========================
#==============================================================================

simpleGLM <- function(fileName) {
  
  setwd(variablesCSVPath)
  projectName <- substr(fileName, 1, regexpr("_",fileName)[1]-1)
  
  # Start writing to an output file
  setwd(resultsGLMPath)
  sink(resultFile, append=TRUE)
  cat("=============================================================")
  cat("\n")
  cat("======================================Project", projectName)
  cat("\n")
  cat("=============================================================")
  cat("\n")
  
  library(aod) # setar na initialização
  setwd(variablesCSVPath)
  dataSample = read.csv(fileName, header=T)
  attach(dataSample) 
  
  predictorsList <- c("existsCommonSlice", "totalCommonSlices","existsCommonPackages","totalCommonPackages", "numberOfCommitsGeoAverage", "numberOfAuthorsGeoAverage", "numberOfChangedFilesGeoAverage", "numberOfChangedLinesGeoAverage", "contributionConclusionDelay", "minimumLifeTimeGeoAverage")

  ## z-score
  for (i in 1:length(predictorsList)){
    pred <- predictorsList[i]
    if (pred== "totalCommonSlices" && length(unique(dataSample$totalCommonSlices))!=1 ){
      dataSample$totalCommonSlices <-((dataSample$totalCommonSlices - mean(dataSample$totalCommonSlices))/sd(dataSample$totalCommonSlices))
    }
    if (pred=="totalCommonPackages" && length(unique(dataSample$totalCommonPackages))!=1 ){
      dataSample$totalCommonPackages <-((dataSample$totalCommonPackages - mean(dataSample$totalCommonPackages))/sd(dataSample$totalCommonPackages))
    }
    if (pred== "numberOfAuthorsGeoAverage" && length(unique(dataSample$numberOfAuthorsGeoAverage))!=1 ){
      dataSample$numberOfAuthorsGeoAverage <-((dataSample$numberOfAuthorsGeoAverage - mean(dataSample$numberOfAuthorsGeoAverage))/sd(dataSample$numberOfAuthorsGeoAverage))
    }
    if (pred== "numberOfCommitsGeoAverage" && length(unique(dataSample$numberOfCommitsGeoAverage))!=1 ){
      dataSample$numberOfCommitsGeoAverage <-((dataSample$numberOfCommitsGeoAverage - mean(dataSample$numberOfCommitsGeoAverage))/sd(dataSample$numberOfCommitsGeoAverage))
    }
    if (pred== "numberOfChangedFilesGeoAverage" && length(unique(dataSample$numberOfChangedFilesGeoAverage))!=1 ){
      dataSample$numberOfChangedFilesGeoAverage <-((dataSample$numberOfChangedFilesGeoAverage - mean(dataSample$numberOfChangedFilesGeoAverage))/sd(dataSample$numberOfChangedFilesGeoAverage))
    }
    if (pred== "numberOfChangedLinesGeoAverage" && length(unique(dataSample$numberOfChangedLinesGeoAverage))!=1 ){
      dataSample$numberOfChangedLinesGeoAverage <-((dataSample$numberOfChangedLinesGeoAverage - mean(dataSample$numberOfChangedLinesGeoAverage))/sd(dataSample$numberOfChangedLinesGeoAverage))
    }
    if (pred== "minimumLifeTimeGeoAverage" && length(unique(dataSample$minimumLifeTimeGeoAverage))!=1 ){
      dataSample$minimumLifeTimeGeoAverage <-((dataSample$minimumLifeTimeGeoAverage - mean(dataSample$minimumLifeTimeGeoAverage))/sd(dataSample$minimumLifeTimeGeoAverage))
    }
    if (pred== "delayIntegrationGeoAverage" && length(unique(dataSample$delayIntegrationGeoAverage))!=1 ){#not used anymore
      dataSample$delayIntegrationGeoAverage <-((dataSample$delayIntegrationGeoAverage - mean(dataSample$delayIntegrationGeoAverage))/sd(dataSample$delayIntegrationGeoAverage))
    }
    if (pred== "contributionConclusionDelay" && length(unique(dataSample$contributionConclusionDelay))!=1 ){
      dataSample$contributionConclusionDelay <-((dataSample$contributionConclusionDelay - mean(dataSample$contributionConclusionDelay))/sd(dataSample$contributionConclusionDelay))	
    }
  }
  ## end z-score
  
  predictorsExcludedList <- c() 
  countPredictorsExcludedList = 1
  significantPredictors_5 <- c() 
  countSignificantPredictors_5 <- 1
  significantPredictors_10 <- c() 
  countSignificantPredictors_10 <- 1
  
  oddsExistsCommonSlice_5 <- c() 
  oddsTotalCommonSlices_5 <- c()
  oddsExistsCommonPackages_5 <- c()
  oddsTotalCommonPackages_5 <- c()
  oddsNumberOfCommitsGeoAverage_5 <- c()
  oddsNumberOfAuthorsGeoAverage_5 <- c()
  oddsDelayIntegrationGeoAverage_5 <- c()
  oddsContributionConclusionDelay_5 <- c()
  oddsMinimumLifeTimeGeoAverage_5 <- c()
  oddsNumberOfChangedFilesGeoAverage_5 <- c()
  oddsNumberOfChangedLinesGeoAverage_5 <- c()	
  countOddsExistsCommonSlice_5 <- 1 
  countOddsTotalCommonSlices_5 <- 1
  countOddsExistsCommonPackages_5 <- 1
  countOddsTotalCommonPackages_5 <- 1
  countOddsNumberOfCommitsGeoAverage_5 <- 1
  countOddsNumberOfAuthorsGeoAverage_5 <- 1
  countOddsDelayIntegrationGeoAverage_5 <- 1
  countOddsContributionConclusionDelay_5 <- 1
  countOddsMinimumLifeTimeGeoAverage_5 <- 1
  countOddsNumberOfChangedFilesGeoAverage_5 <- 1
  countOddsNumberOfChangedLinesGeoAverage_5 <- 1	
  

  listResults <- list()
  
  for (i in 1:length(predictorsList)){
    
    predictor <- predictorsList[i]
    pair = paste("isConflicting ~ ", predictor)
    sampleModel = glm(pair, data=dataSample, family = binomial(link="logit"))
    summary(sampleModel)

    validValue = paste(coefficients(sampleModel)[predictor]) 
    if (validValue != "NA") { 
      # o valor do coef x
      coeffValue = round(summary(sampleModel)$coefficients[predictor,1],2) #coeffValue = round(summary(sampleModel)$coefficients[2,1],2)
      # o p-vaue do coef x
      coeffPValue = summary(sampleModel)$coefficients[predictor,4] #coeffPValue = summary(sampleModel)$coefficients[2,4]
      if(coeffPValue<=0.05){
        significantPredictors_5[countSignificantPredictors_5] <- predictor
        countSignificantPredictors_5 <- countSignificantPredictors_5 + 1
      } else if(coeffPValue<=0.1){ 
        significantPredictors_10[countSignificantPredictors_10] <- predictor
        countSignificantPredictors_10 <- countSignificantPredictors_10 + 1
      }
      #Null Deviance
      nullDevianceSample = round(summary(sampleModel)$null.deviance,2)
      #Deviance
      devianceSample = round(summary(sampleModel)$deviance,2)
      #AIC
      aicSample = round(summary(sampleModel)$aic,2)
      ## The percentage of the deviance explained is a ratio of the deviance of the null model (contains only the intercept) and the deviance of the final model.
      percDevianceExplained = round((1 - devianceSample/nullDevianceSample)*100,2)
      ## Wald Test
      waldTest = wald.test(b = coef(sampleModel), Sigma = vcov(sampleModel), Terms = 2:2) #Terms vai depender do numero de var no summary
      waldTestResult = waldTest$result$chi2
      chi2Sample = round(waldTestResult[1],2)
      dfSample = waldTestResult[2]
      pValueSample = waldTestResult[3]
      ##  In terms of  Odds  change x
      oddChanges = round(exp(coef(sampleModel)[predictor]),2) #oddChanges = round(exp(coef(sampleModel)[2]),2)
      oddChanges
      ## In terms of percent change
      percOddChanges = round((oddChanges - 1)*100,2)
      percOddChanges
      if(coeffPValue<=0.05){
        if(predictor == "existsCommonSlice"){					
          oddsExistsCommonSlice_5[countOddsExistsCommonSlice_5] <- percOddChanges
          countOddsExistsCommonSlice_5 <- countOddsExistsCommonSlice_5 + 1
        } else if(predictor == "totalCommonSlices"){					
          oddsTotalCommonSlices_5[countOddsTotalCommonSlices_5] <- percOddChanges
          countOddsTotalCommonSlices_5 <- countOddsTotalCommonSlices_5 + 1
        } else if(predictor == "existsCommonPackages"){					
          oddsExistsCommonPackages_5[countOddsExistsCommonPackages_5] <- percOddChanges
          countOddsExistsCommonPackages_5 <- countOddsExistsCommonPackages_5 + 1
        }  else if(predictor == "totalCommonPackages"){					
          oddsTotalCommonPackages_5[countOddsTotalCommonPackages_5] <- percOddChanges
          countOddsTotalCommonPackages_5 <- countOddsTotalCommonPackages_5 + 1
        } else if(predictor == "numberOfCommitsGeoAverage"){					
          oddsNumberOfCommitsGeoAverage_5[countOddsNumberOfCommitsGeoAverage_5] <- percOddChanges
          countOddsNumberOfCommitsGeoAverage_5 <- countOddsNumberOfCommitsGeoAverage_5 + 1
        } else if(predictor == "numberOfAuthorsGeoAverage"){					
          oddsNumberOfAuthorsGeoAverage_5[countOddsNumberOfAuthorsGeoAverage_5] <- percOddChanges
          countOddsNumberOfAuthorsGeoAverage_5 <- countOddsNumberOfAuthorsGeoAverage_5 + 1
        } else if(predictor == "delayIntegrationGeoAverage"){					
          oddsDelayIntegrationGeoAverage_5[countOddsDelayIntegrationGeoAverage_5] <- percOddChanges
          countOddsDelayIntegrationGeoAverage_5 <- countOddsDelayIntegrationGeoAverage_5 + 1
        } else if(predictor == "contributionConclusionDelay"){					
          oddsContributionConclusionDelay_5[countOddsContributionConclusionDelay_5] <- percOddChanges
          countOddsContributionConclusionDelay_5 <- countOddsContributionConclusionDelay_5 + 1
        } else if(predictor == "minimumLifeTimeGeoAverage"){					
          oddsMinimumLifeTimeGeoAverage_5[countOddsMinimumLifeTimeGeoAverage_5] <- percOddChanges
          countOddsMinimumLifeTimeGeoAverage_5 <- countOddsMinimumLifeTimeGeoAverage_5 + 1
        } else if(predictor == "numberOfChangedFilesGeoAverage"){					
          oddsNumberOfChangedFilesGeoAverage_5[countOddsNumberOfChangedFilesGeoAverage_5] <- percOddChanges
          countOddsNumberOfChangedFilesGeoAverage_5 <- countOddsNumberOfChangedFilesGeoAverage_5 + 1
        } else if(predictor == "numberOfChangedLinesGeoAverage"){					
          oddsNumberOfChangedLinesGeoAverage_5[countOddsNumberOfChangedLinesGeoAverage_5] <- percOddChanges
          countOddsNumberOfChangedLinesGeoAverage_5 <- countOddsNumberOfChangedLinesGeoAverage_5 + 1
        }
      }
      if(coeffPValue<=0.1){ #Não considero mais abaixo de 10% - apenas 5% mesmo...
        #oddsPredictors_10[countOddsPredictors_10] <- percOddChanges
        #countOddsPredictors_10 <- countOddsPredictors_10 + 1
      }
      
      sink() ## Stop writing to the file
      
      print(paste(projectName,",",predictor,",",coeffValue,",",coeffPValue,",", nullDevianceSample,",",devianceSample,",",aicSample,",",percDevianceExplained,"%,",oddChanges,",", percOddChanges,"%,",chi2Sample,",",dfSample,",",pValueSample))
      # Append to the file
      setwd(resultsGLMPath)
      sink(resultFile, append=TRUE)
      if(coeffPValue <= 0.05){
        print(paste("Predictor = ",predictor,", p-value = ",coeffPValue,", Odds Ratio = ",oddChanges,", %Odds = ", percOddChanges,"%"))
      }
      sink() ## Stop writing to the file
    }else{
      predictorsExcludedList[countPredictorsExcludedList] <-  paste(projectName," - ",predictor)
      countPredictorsExcludedList <- countPredictorsExcludedList + 1
    }	# if (validValue != "NA")	
  }#for
  # Append to the file
  setwd(resultsGLMPath)
  sink(resultFile, append=TRUE)
  print(paste("Total predictor(s) considering p-value <= 0.05 = ", length(significantPredictors_5)))
  if(length(predictorsExcludedList>0)){
    
    for (i in 1:length(predictorsExcludedList)){
      print(paste("Predictor(s) not evaluated = ", paste(trimws(substr(predictorsExcludedList, regexpr("-",predictorsExcludedList)+1, nchar(predictorsExcludedList))),collapse=",")))
      
    }
  }
  
  sink() ## Stop writing to the file
  
  listResults <- list(predictorsExcluded = predictorsExcludedList, sigPredictors_5 = significantPredictors_5, sigPredictors_10 = significantPredictors_10, percOddsSlices_5 = oddsExistsCommonSlice_5, percOddsTotalCommonSlices_5 = oddsTotalCommonSlices_5, percOddsExistsCommonPackages_5 = oddsExistsCommonPackages_5, percOddsTotalCommonPackages_5 = oddsTotalCommonPackages_5, percOddsCommits_5 = oddsNumberOfCommitsGeoAverage_5, percOddsAuthors_5 = oddsNumberOfAuthorsGeoAverage_5, percOddsDelay_5 = oddsDelayIntegrationGeoAverage_5, percOddsContributionConclusionDelay_5 = oddsContributionConclusionDelay_5, percOddsLifeTime_5 = oddsMinimumLifeTimeGeoAverage_5, percOddsFiles_5 = oddsNumberOfChangedFilesGeoAverage_5, percOddsLines_5 = oddsNumberOfChangedLinesGeoAverage_5)

  return (listResults)
  
}


listSignificantPredictors <- function(predictorsList, projectsList){
  if(length(predictorsList)> 0){
    #get the ocorrence value
    significantePredictorsOcurrence <- table(predictorsList)
    for (i in 1:length(names(significantePredictorsOcurrence))){
      valueSigOcurrence = significantePredictorsOcurrence[names(significantePredictorsOcurrence)==names(significantePredictorsOcurrence)[i]]
      print(paste(names(significantePredictorsOcurrence)[i]," = ",valueSigOcurrence, " which corresponds to ",round((valueSigOcurrence/length(projectsList))*100,2),"% of the total projects"))
    }
  }
  
}

listPercentualOddsPredictors <- function(oddsList, predictorName){
  if(length(oddsList)> 0){
    print(paste(predictorName," ranges from ", oddsList[which.min(oddsList)],"% to ",oddsList[which.max(oddsList)],"% ::: Mean = ",round(mean(oddsList),2),"; Meadian = ", round(median(oddsList),2),"; Std = ",round(sd(oddsList),2)))
  }
}



analysisGLMByPredictor <- function(){
  unlink(resultFile, recursive = FALSE, force = FALSE)
  setwd(rAnalysisPath)

  projects <- readConfigProperties("sampleProjectsList.csv")
  predictorsExcluded <- c()
  countPredictorsExcluded <-1
  
  significantPredictors_5 <- c()
  countSgnificantPredictors_5 <-1
  
  significantPredictors_10 <- c()   
  countSignificantPredictors_10 <-1
  
  oddsExistsCommonSlice_5 <- c() # armazena o % do odds ratio do preditores com p-value <= 0.05
  oddsTotalCommonSlices_5 <- c()
  oddsExistsCommonPackages_5 <- c()
  oddsTotalCommonPackages_5 <- c()
  oddsNumberOfCommitsGeoAverage_5 <- c()
  oddsNumberOfAuthorsGeoAverage_5 <- c()
  oddsDelayIntegrationGeoAverage_5 <- c()
  oddsContributionConclusionDelay_5 <- c()
  oddsMinimumLifeTimeGeoAverage_5 <- c()
  oddsNumberOfChangedFilesGeoAverage_5 <- c()
  oddsNumberOfChangedLinesGeoAverage_5 <- c()	
  countOddsExistsCommonSlice_5 <- 1 # armazena o contador para  odds ratio do preditores com p-value <= 0.05
  countOddsTotalCommonSlices_5 <- 1
  countOddsExistsCommonPackages_5 <- 1
  countOddsTotalCommonPackages_5 <- 1
  countOddsNumberOfCommitsGeoAverage_5 <- 1
  countOddsNumberOfAuthorsGeoAverage_5 <- 1
  countOddsDelayIntegrationGeoAverage_5 <- 1
  countOddsContributionConclusionDelay_5 <- 1
  countOddsMinimumLifeTimeGeoAverage_5 <- 1
  countOddsNumberOfChangedFilesGeoAverage_5 <- 1
  countOddsNumberOfChangedLinesGeoAverage_5 <- 1	
  
  for (i in 1:length(projects)) {
    # print (projects[i])
    resultsGLM = simpleGLM(projects[i])
    if (length(resultsGLM$predictorsExcluded > 0)){
      predictorsExcluded[countPredictorsExcluded] <- resultsGLM$predictorsExcluded
      countPredictorsExcluded <- countPredictorsExcluded + 1
    }
    if (length(resultsGLM$sigPredictors_5) > 0){
      print(paste("significante = ", length(resultsGLM$sigPredictors_5)," preditores = ", paste(resultsGLM$sigPredictors_5,collapse=",")))
      for(i in 1:length(resultsGLM$sigPredictors_5)){
        significantPredictors_5[countSgnificantPredictors_5] <- resultsGLM$sigPredictors_5[i]
        countSgnificantPredictors_5 <- countSgnificantPredictors_5 + 1
      }
    }
    if (length(resultsGLM$sigPredictors_10) > 0){
      print(paste("significante = ", length(resultsGLM$sigPredictors_10)," preditores = ", paste(resultsGLM$sigPredictors_10,collapse=",")))
      for(i in 1:length(resultsGLM$sigPredictors_10)){
        significantPredictors_10[countSignificantPredictors_10] <- resultsGLM$sigPredictors_10[i]
        countSignificantPredictors_10 <- countSignificantPredictors_10 + 1
      }
    }
    
    #comeca a acumlar os valores de odds percent para cada preditor para no summary checar o maximo e mínimo de efeito em cada amostra passada
    if (length(resultsGLM$percOddsSlices_5) > 0){
      for(i in 1:length(resultsGLM$percOddsSlices_5)){
        oddsExistsCommonSlice_5[countOddsExistsCommonSlice_5] <- resultsGLM$percOddsSlices_5[i]
        countOddsExistsCommonSlice_5 <- countOddsExistsCommonSlice_5 + 1
      }
    }
    if (length(resultsGLM$percOddsTotalCommonSlices_5) > 0){
      for(i in 1:length(resultsGLM$percOddsTotalCommonSlices_5)){
        oddsTotalCommonSlices_5[countOddsTotalCommonSlices_5] <- resultsGLM$percOddsTotalCommonSlices_5[i]
        countOddsTotalCommonSlices_5 <- countOddsTotalCommonSlices_5 + 1
      }
    }
    if (length(resultsGLM$percOddsExistsCommonPackages_5) > 0){
      for(i in 1:length(resultsGLM$percOddsExistsCommonPackages_5)){
        oddsExistsCommonPackages_5[countOddsExistsCommonPackages_5] <- resultsGLM$percOddsExistsCommonPackages_5[i]
        countOddsExistsCommonPackages_5 <- countOddsExistsCommonPackages_5 + 1
      }
    }
    if (length(resultsGLM$percOddsTotalCommonPackages_5) > 0){
      for(i in 1:length(resultsGLM$percOddsTotalCommonPackages_5)){
        oddsTotalCommonPackages_5[countOddsTotalCommonPackages_5] <- resultsGLM$percOddsTotalCommonPackages_5[i]
        countOddsTotalCommonPackages_5 <- countOddsTotalCommonPackages_5 + 1
      }
    }
    if (length(resultsGLM$percOddsCommits_5) > 0){
      for(i in 1:length(resultsGLM$percOddsCommits_5)){
        oddsNumberOfCommitsGeoAverage_5[countOddsNumberOfCommitsGeoAverage_5] <- resultsGLM$percOddsCommits_5[i]
        countOddsNumberOfCommitsGeoAverage_5 <- countOddsNumberOfCommitsGeoAverage_5 + 1
      }
    }		
    if (length(resultsGLM$percOddsAuthors_5) > 0){
      for(i in 1:length(resultsGLM$percOddsAuthors_5)){
        oddsNumberOfAuthorsGeoAverage_5[countOddsNumberOfAuthorsGeoAverage_5] <- resultsGLM$percOddsAuthors_5[i]
        countOddsNumberOfAuthorsGeoAverage_5 <- countOddsNumberOfAuthorsGeoAverage_5 + 1
      }
    }		
    if (length(resultsGLM$percOddsDelay_5) > 0){
      for(i in 1:length(resultsGLM$percOddsDelay_5)){
        oddsDelayIntegrationGeoAverage_5[countOddsDelayIntegrationGeoAverage_5] <- resultsGLM$percOddsDelay_5[i]
        countOddsDelayIntegrationGeoAverage_5 <- countOddsDelayIntegrationGeoAverage_5 + 1
      }
    }		
    if (length(resultsGLM$percOddsContributionConclusionDelay_5) > 0){
      for(i in 1:length(resultsGLM$percOddsContributionConclusionDelay_5)){
        oddsContributionConclusionDelay_5[countOddsContributionConclusionDelay_5] <- resultsGLM$percOddsContributionConclusionDelay_5[i]
        countOddsContributionConclusionDelay_5 <- countOddsContributionConclusionDelay_5 + 1
      }
    }			
    if (length(resultsGLM$percOddsLifeTime_5) > 0){
      for(i in 1:length(resultsGLM$percOddsLifeTime_5)){
        oddsMinimumLifeTimeGeoAverage_5[countOddsMinimumLifeTimeGeoAverage_5] <- resultsGLM$percOddsLifeTime_5
        countOddsMinimumLifeTimeGeoAverage_5 <- countOddsMinimumLifeTimeGeoAverage_5 + 1
      }
    }			
    if (length(resultsGLM$percOddsFiles_5) > 0){
      for(i in 1:length(resultsGLM$percOddsFiles_5)){
        oddsNumberOfChangedFilesGeoAverage_5[countOddsNumberOfChangedFilesGeoAverage_5] <- resultsGLM$percOddsFiles_5
        countOddsNumberOfChangedFilesGeoAverage_5 <- countOddsNumberOfChangedFilesGeoAverage_5 + 1
      }
    }
    if (length(resultsGLM$percOddsLines_5) > 0){
      for(i in 1:length(resultsGLM$percOddsLines_5)){
        oddsNumberOfChangedLinesGeoAverage_5[countOddsNumberOfChangedLinesGeoAverage_5] <- resultsGLM$percOddsLines_5
        countOddsNumberOfChangedLinesGeoAverage_5 <- countOddsNumberOfChangedLinesGeoAverage_5 + 1
      }
    }		
  }
  #debbuging
  if(length(predictorsExcluded>0)){
    print("=========================================================================")
    print("==========================projetos que não possuem casos para preditores")
    print("==========================================================================")
    
    for (i in 1:length(predictorsExcluded)){
      print(predictorsExcluded[i])
    }
  }
  
  #debbuging
  if(length(significantPredictors_5)>0){
    print("=========================================================================")
    print("==========================significantPredictors_5 = ")
    
    # única linha
    print(paste(significantPredictors_5, collapse=","))
    print("==========================================================================")
    #linha a linha
    # for (i in 1:length(significantPredictors_5)){
    #		print(paste(significantPredictors_5[i], collapse=","))
    # }
  }
  #debbuging
  if(length(significantPredictors_5)>0){
    print("=========================================================================")
    print("==========================significantPredictors_10 = ")
    
    print(paste(significantPredictors_5, collapse=","))
  }
  # Start writing to an output file
  sink(resultFile, append=TRUE)
  #cat("==============================================================================================================")
  #cat("\n")
  #cat("=====================================START SUMMARY RESULTS"====================================================)
  #cat("\n")
  #cat("==============================================================================================================")
  #cat("\n")
  
  
  print("==============================================================================================================")
  print("======================================START SUMMARY RESULTS===================================================")
  print("==============================================================================================================")
  print(paste("================Total Evaluated Projects = ",length(projects)))
  print(paste("================Total projects with one or more predictors not evaluated = ",length(predictorsExcluded)))

  #get the ocorrence of excluded predictors
  listOcorrencesExcludedPredictors <- c()	
  if(length(predictorsExcluded)>0){
    for(i in 1:length(predictorsExcluded)){
      # get the predictor name
      listOcorrencesExcludedPredictors[i]<- trimws(substr(predictorsExcluded[i], regexpr(" - ",predictorsExcluded[i])[1]+2, nchar(predictorsExcluded[i])))
    }
    #get the ocorrence value
    predictorsOcurrence <- table(listOcorrencesExcludedPredictors)
    for (i in 1:length(names(predictorsOcurrence))){
      valueOcurrence = predictorsOcurrence[names(predictorsOcurrence)==names(predictorsOcurrence)[i]]
      print(paste(names(predictorsOcurrence)[i]," = ",valueOcurrence," which corresponds to ",round((valueOcurrence/length(projects))*100,2),"% of the total projects"))
      #ocorrence[names(ocorrence) == names(ocorrence)[1]]
    }
  }
  
  #get the ocorrence of significant predictors with 5%
  print("================Summary of resulting predictors considering p-value <= 0.05")
  listSignificantPredictors(significantPredictors_5, projects)
  print("================Odds Ratio Range considering predictors with p-value <= 0.05")
  listPercentualOddsPredictors(oddsExistsCommonSlice_5, "existsCommonSlice")
  listPercentualOddsPredictors(oddsTotalCommonSlices_5, "totalCommonSlices")
  listPercentualOddsPredictors(oddsExistsCommonPackages_5, "existsCommonPackages")
  listPercentualOddsPredictors(oddsTotalCommonPackages_5, "totalCommonPackages")
  listPercentualOddsPredictors(oddsNumberOfCommitsGeoAverage_5, "numberOfCommitsGeoAverage")
  listPercentualOddsPredictors(oddsNumberOfAuthorsGeoAverage_5, "numberOfAuthorsGeoAverage")
  # listPercentualOddsPredictors(oddsDelayIntegrationGeoAverage_5, "delayIntegrationGeoAverage") #not used anymore 
  listPercentualOddsPredictors(oddsContributionConclusionDelay_5, "contributionConclusionDelay")
  listPercentualOddsPredictors(oddsMinimumLifeTimeGeoAverage_5, "minimumLifeTimeGeoAverage")
  listPercentualOddsPredictors(oddsNumberOfChangedFilesGeoAverage_5, "numberOfChangedFilesGeoAverage")
  listPercentualOddsPredictors(oddsNumberOfChangedLinesGeoAverage_5, "numberOfChangedLinesGeoAverage")
  
  #get the ocorrence of significant predictors with 10%
  print("================Summary of resulting predictors considering p-value <= 0.1")
  listSignificantPredictors(significantPredictors_10, projects)
  
  sink()# Stop writing to the file
  setwd(rAnalysisPath)
}


analysisGLMByPredictor()
print ("Anaysis per predictor done")

