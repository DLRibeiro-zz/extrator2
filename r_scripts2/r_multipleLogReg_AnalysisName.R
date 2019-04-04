# set paths
rAnalysisPath = getwd()
#setwd("..")

setwd("input") # csv file variables 
variablesCSVPath = getwd()

pathResults = "MultipleGLM_Results"
dir.create(file.path(rAnalysisPath, pathResults), showWarnings = FALSE)
setwd(file.path(rAnalysisPath, pathResults))
resultsGLMPath = getwd()

resultFile = "analysis_output_Multiple_GLM.txt"


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

mergesFrequency <- function(fileName) {
  setwd(variablesCSVPath)
  f <- read.csv(fileName, header=T)
  merges <- nrow(f)
  conflictingMerges <- sum(f$isConflicting == 1)
  cleanMerges <- sum(f$isConflicting == 0)
  percConflicting <- round((conflictingMerges/merges)*100,2)
  percClean <- round((cleanMerges/merges)*100,2)
  return (list(merges = merges, clean = cleanMerges, pClean = percClean, conflicting = conflictingMerges, pConflicting = percConflicting))
}

#==============================================================================
#============================MULTIPLE LOGISTIC REGRESSION========================
#==============================================================================

# selectModel = 1 means step method and selectModel = 0 means no step method
# usesVIF = true (check collinearity ); usesVIF = false (do not check collinearity)
multipleGLM <- function(fileName, responseVariable, predictorsVariablesList, selectModel, usesVIF) { 
  mergesFreq <- mergesFrequency(fileName)
  projectName <- substr(fileName, 1, regexpr("_",fileName)[1]-1)
  
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
  oddsNumberOfChangedFilesGeoAverage_5 <- c()
  oddsNumberOfChangedLinesGeoAverage_5 <- c()	
  #oddsDelayIntegrationGeoAverage_5 <- c() #not used anymore
  #oddsDeltaIntegrationSlice_5 <- c() #not used anymore
  oddsMinimumLifeTimeGeoAverage_5 <- c()
  oddsContributionConclusionDelay_5 <- c()
  
  countOddsExistsCommonSlice_5 <- 1 
  countOddsTotalCommonSlices_5 <- 1
  countOddsExistsCommonPackages_5 <- 1
  countOddsTotalCommonPackages_5 <- 1
  countOddsNumberOfCommitsGeoAverage_5 <- 1
  countOddsNumberOfAuthorsGeoAverage_5 <- 1
  countOddsNumberOfChangedFilesGeoAverage_5 <- 1
  countOddsNumberOfChangedLinesGeoAverage_5 <- 1	
  #countOddsDelayIntegrationGeoAverage_5 <- 1 #not used anymore
  #countOddsDeltaIntegrationSlice_5 <- 1  #not used anymore
  countOddsMinimumLifeTimeGeoAverage_5 <- 1
  countOddsContributionConclusionDelay_5 <- 1
  
  oddsExistsCommonSlice_10 <- c() 
  oddsTotalCommonSlices_10 <- c()
  oddsExistsCommonPackages_10 <- c()
  oddsTotalCommonPackages_10 <- c()
  oddsNumberOfCommitsGeoAverage_10 <- c()
  oddsNumberOfAuthorsGeoAverage_10 <- c()
  oddsNumberOfChangedFilesGeoAverage_10 <- c()
  oddsNumberOfChangedLinesGeoAverage_10 <- c()	
  #oddsDelayIntegrationGeoAverage_10 <- c() #not used anymore
  #oddsDeltaIntegrationSlice_10 <- c() #not used anymore
  oddsMinimumLifeTimeGeoAverage_10 <- c()
  oddsContributionConclusionDelay_10 <- c()
  
  countOddsExistsCommonSlice_10 <- 1 
  countOddsTotalCommonSlices_10 <- 1
  countOddsExistsCommonPackages_10 <- 1
  countOddsTotalCommonPackages_10 <- 1
  countOddsNumberOfCommitsGeoAverage_10 <- 1
  countOddsNumberOfAuthorsGeoAverage_10 <- 1
  countOddsNumberOfChangedFilesGeoAverage_10 <- 1
  countOddsNumberOfChangedLinesGeoAverage_10 <- 1
  #countOddsDelayIntegrationGeoAverage_10 <- 1 #not used anymore
  #countOddsDeltaIntegrationSlice_10 <- 1 #not used anymore
  countOddsMinimumLifeTimeGeoAverage_10 <- 1	
  countOddsContributionConclusionDelay_10 <- 1	
  
  
  devianceSample <- 0
  aicSample <- 0
  percDevianceExplained <- 0
  chi2Sample <- 0
  dfSample <- 0
  pValueSample <- 0
  
  results <- list()
  library(aod)
  setwd(variablesCSVPath)
  dataSample <- read.csv(fileName, header=T, sep =",")
  predictorsList <- ""#predictorsVariablesList 
  response<- responseVariable
  if(usesVIF=="true"){
    predictorsList <- VIF_Analysis(fileName, responseVariable, predictorsVariablesList)
  }else {
    predictorsList <- predictorsVariablesList  
  }
  
  ## Z-score
  for (i in 1:length(predictorsList)){
    pred <- predictorsList[i]
    
    if (pred== "totalCommonSlices" && length(unique(dataSample$totalCommonSlices))!=1 ){
      dataSample$totalCommonSlices <-((dataSample$totalCommonSlices - mean(dataSample$totalCommonSlices))/sd(dataSample$totalCommonSlices))
    }
    if (pred== "totalCommonPackages" && length(unique(dataSample$totalCommonPackages))!=1 ){ 
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
    #if (pred== "delayIntegrationGeoAverage" && length(unique(dataSample$delayIntegrationGeoAverage))!=1 ){ 
    #  dataSample$delayIntegrationGeoAverage <-((dataSample$delayIntegrationGeoAverage - mean(dataSample$delayIntegrationGeoAverage))/sd(dataSample$delayIntegrationGeoAverage))
    #}
    if (pred== "contributionConclusionDelay" && length(unique(dataSample$contributionConclusionDelay))!=1 ){ 
      print(paste("padronizou preditor ",pred)) #debgging
      dataSample$contributionConclusionDelay <-((dataSample$contributionConclusionDelay - mean(dataSample$contributionConclusionDelay))/sd(dataSample$contributionConclusionDelay))
    }
  }
  ## end Z-score
  
  
  
  model.final = "" 
  if (selectModel == 1){
    variablesModelNull <- formula(paste(response, '~', 1))
    model.null <- glm(variablesModelNull, data=dataSample, family = binomial(link="logit"))
    
    variablesModelFull <- formula(paste(response, '~', paste(predictorsList, collapse = '+')))
    model.full <- glm(variablesModelFull, data=dataSample, family = binomial(link="logit"))
    model.final <- step(model.null, scope = list(upper=model.full), direction="both", test="Chisq", data=dataSample)
    
  } else if (selectModel == 0){
    variablesModelFull <- formula(paste(response, '~', paste(predictorsList, collapse = '+')))
    model.final <- glm(variablesModelFull, data=dataSample, family = binomial(link="logit"))
  }
  summary(model.final)
  
  
  #obtendo a matriz com coeficientes e seu valores
  coeffs <- coefficients(model.final)
  coefsExcluded <-c()
  countCoefsExcluded <-1
  for (i in 1:length(coeffs)){
    value <- paste(coeffs[i])
    if (value=="NA"){
      coefsExcluded[countCoefsExcluded]<- names(coeffs[i])
      countCoefsExcluded <- countCoefsExcluded + 1
    }
  }
  
  if (length(coefsExcluded)>0){		
    # tmp <- c()
    for (i in 1:length(coefsExcluded)){
      for (j in 1:length(predictorsList)){
        print(coefsExcluded[i] == paste(predictorsList[j])) #debbuging
        if (coefsExcluded[i] == paste(predictorsList[j])){
          predictorsList <- predictorsList[-j]					
        }
      }
    }
    print(paste("preditores a serem excluidos = ", paste(coefsExcluded, collapse=",")))
  }
  
  
  print("============================================================================================")
  print(paste("=========================INICIO DADOS DO PROJETO --",projectName,"======================="))
  print("============================================================================================")
  # Start writing to an output file
  setwd(resultsGLMPath)
  sink(resultFile, append=TRUE)
  cat("=============================================================")
  cat("\n")
  cat("======================================Project", projectName)
  cat("\n")
  cat("=============================================================")
  cat("\n")
  
  
  predictorsNameList <- predictorsList	
  print(paste("Total merges = ",mergesFreq$merges,", % Clean merges = ",mergesFreq$pClean,", % Conflicting merges = ", mergesFreq$pConflicting))
  print(paste("Total predictors before running GLM = ",length(predictorsNameList), "lista = ",paste(predictorsNameList, collapse=",")))
  sink()	# Stop writing to the file
  
  if (length(predictorsNameList)>=1){
    ##matriz de coeficients
    matrixCoefValues <- summary(model.final)$coefficients
    print(paste("Predictor, Estimate, Pr(>|z|)")) #cabeÃ§alho
    for (i in 1:length(predictorsNameList)) {
      predictorName <- predictorsNameList[i]
      validValue = paste(coefficients(model.final)[predictorName])
      if (validValue != "NA"){
        if (matrixCoefValues[predictorsNameList[i],4] <=0.05) {
          significantPredictors_5[countSignificantPredictors_5] <- predictorsNameList[i]
          countSignificantPredictors_5<- countSignificantPredictors_5+1
        }else { 
          significantPredictors_10[countSignificantPredictors_10] <- predictorsNameList[i]
          countSignificantPredictors_10 <- countSignificantPredictors_10+1
        }			
      }
    }#for
    
    print(paste("Dos ",length(predictorsNameList)," preditores resultantes no modelo final"))
    print(paste(length(significantPredictors_5), " sÃ£o significantes a 5% e ",length(significantPredictors_10)," sÃ£o significantes a 10%"))
    
    # Start writing to an output file
    setwd(resultsGLMPath)
    sink(resultFile, append=TRUE)
    
    if (length(significantPredictors_5)>=1){
      print(paste(length(significantPredictors_5), " predictor(s) with p-value <= 0.05 = ", paste(significantPredictors_5,collapse=",")))	
    }else {
      print("There are no predictors with p <= 0.05")
    }
    
    
    if (length(significantPredictors_10)>=1){
      print(paste(length(significantPredictors_10), " predictor(s) with p-value > 0.05 = ",paste(significantPredictors_10,collapse=",")))		
    }else {
      print("There are no predictors with p > 0.05")
    }		
    
    sink()	# Stop writing to the file
    
    if(length(significantPredictors_5)>= 1 | length(significantPredictors_10)>=1){
      print(paste("E aqui tb 1"))#debbuging
      #Null Deviance
      nullDevianceSample = round(summary(model.final)$null.deviance,2)
      #Deviance of the model
      devianceSample = round(summary(model.final)$deviance,2)
      #AIC
      aicSample = round(summary(model.final)$aic,2)
      percDevianceExplained = round((1 - devianceSample/nullDevianceSample)*100,2)
      
      #teste do qui-qadrado para o modelo
      waldTest = wald.test(b = coef(model.final), Sigma = vcov(model.final), Terms = 2:length(coef(model.final))) #Terms vai depender do numero de var no summary
      
      waldTestResult = waldTest$result$chi2
      waldTestResult
      
      chi2Sample = round(waldTestResult[1],2)
      dfSample = waldTestResult[2]
      pValueSample = waldTestResult[3]
      
      if (pValueSample <=0.05) {
        print(paste("The statistical analysis by the chi-squared test has demonstrated significant difference (p = ",pValueSample,")"))
        # Start writing to an output file
        setwd(resultsGLMPath)
        sink(resultFile, append=TRUE)
        print(paste("The statistical analysis by the chi-squared test has demonstrated significant difference (p = ",pValueSample,")"))
        sink()	# Stop writing to the file	
      }else { 
        print(paste("The statistical analysis by the chi-squared test has not demonstrated any significant difference (p = ",pValueSample,")"))
        # Start writing to an output file
        setwd(resultsGLMPath)
        sink(resultFile, append=TRUE)
        print(paste("The statistical analysis by the chi-squared test has not demonstrated any significant difference (p = ",pValueSample,")"))
        sink()	# Stop writing to the file	
      }
      
      
      if (length(significantPredictors_5)>=1){
        print("####################### APENAS PREDITORES SIGNIFICATIVOS a 5%##########################################")
        # Start writing to an output file
        setwd(resultsGLMPath)
        sink(resultFile, append=TRUE)
        print("============Odds Ratio for predictors with p-value <= 0.05")
        sink()	# Stop writing to the file	
        for (i in 1:length(significantPredictors_5)) { #apenas significativos
          predictor <- significantPredictors_5[i]
          pvalue <- matrixCoefValues[significantPredictors_5[i],4]
          oddChanges = round(exp(coeffs[significantPredictors_5[i]]),2) #sÃ³ os significativos
          percOddChanges = round((oddChanges - 1)*100,2)	
          if(predictor == "existsCommonSlice"){					
            oddsExistsCommonSlice_5[countOddsExistsCommonSlice_5] <- percOddChanges
            countOddsExistsCommonSlice_5 <- countOddsExistsCommonSlice_5 + 1
          }else if(predictor == "totalCommonSlices"){					
            oddsTotalCommonSlices_5[countOddsTotalCommonSlices_5] <- percOddChanges
            countOddsTotalCommonSlices_5 <- countOddsTotalCommonSlices_5 + 1
          }else if(predictor == "existsCommonPackages"){					
            oddsExistsCommonPackages_5[countOddsExistsCommonPackages_5] <- percOddChanges
            countOddsExistsCommonPackages_5 <- countOddsExistsCommonPackages_5 + 1
          }else if(predictor == "totalCommonPackages"){					
            oddsTotalCommonPackages_5[countOddsTotalCommonPackages_5] <- percOddChanges
            countOddsTotalCommonPackages_5 <- countOddsTotalCommonPackages_5 + 1
          }else if(predictor == "numberOfCommitsGeoAverage"){					
            oddsNumberOfCommitsGeoAverage_5[countOddsNumberOfCommitsGeoAverage_5] <- percOddChanges
            countOddsNumberOfCommitsGeoAverage_5 <- countOddsNumberOfCommitsGeoAverage_5 + 1
          }else if(predictor == "numberOfAuthorsGeoAverage"){					
            oddsNumberOfAuthorsGeoAverage_5[countOddsNumberOfAuthorsGeoAverage_5] <- percOddChanges
            countOddsNumberOfAuthorsGeoAverage_5 <- countOddsNumberOfAuthorsGeoAverage_5 + 1
          }#else if(predictor == "delayIntegrationGeoAverage"){					
          #oddsDelayIntegrationGeoAverage_5[countOddsDelayIntegrationGeoAverage_5] <- percOddChanges
          #countOddsDelayIntegrationGeoAverage_5 <- countOddsDelayIntegrationGeoAverage_5 + 1
          #}else if(predictor == "deltaIntegration"){					
          #oddsDeltaIntegrationSlice_5[countOddsDeltaIntegrationSlice_5] <- percOddChanges
          #countOddsDeltaIntegrationSlice_5 <- countOddsDeltaIntegrationSlice_5 + 1
          #}
          else if(predictor == "numberOfChangedFilesGeoAverage"){					
            oddsNumberOfChangedFilesGeoAverage_5[countOddsNumberOfChangedFilesGeoAverage_5] <- percOddChanges
            countOddsNumberOfChangedFilesGeoAverage_5 <- countOddsNumberOfChangedFilesGeoAverage_5 + 1
          }else if(predictor == "numberOfChangedLinesGeoAverage"){					
            oddsNumberOfChangedLinesGeoAverage_5[countOddsNumberOfChangedLinesGeoAverage_5] <- percOddChanges
            countOddsNumberOfChangedLinesGeoAverage_5 <- countOddsNumberOfChangedLinesGeoAverage_5 + 1
          }else if(predictor == "minimumLifeTimeGeoAverage"){					
            oddsMinimumLifeTimeGeoAverage_5[countOddsMinimumLifeTimeGeoAverage_5] <- percOddChanges
            countOddsMinimumLifeTimeGeoAverage_5 <- countOddsMinimumLifeTimeGeoAverage_5 + 1
          }else if(predictor == "contributionConclusionDelay"){					
            oddsContributionConclusionDelay_5[countOddsContributionConclusionDelay_5] <- percOddChanges
            countOddsContributionConclusionDelay_5 <- countOddsContributionConclusionDelay_5 + 1
          }
          
          
          #para imprimir em relatÃ³rio texto livre
          print(paste("odds de ",predictor," = ",oddChanges," que representa ",percOddChanges,"% chances de ocorrer conflito"))
          # Start writing to an output file			
          setwd(resultsGLMPath)
          sink(resultFile, append=TRUE)
          print(paste("Predictor = ",predictor,", Odds Ratio = ",oddChanges,", %Odds = ",percOddChanges, ", p-value = ",pvalue)) 
          sink()	# Stop writing to the file	
        }#for
        
      } #if
      if (length(significantPredictors_10)>=1){ 
        print("####################### APENAS PREDITORES SIGNIFICATIVOS a 10% ##########################################")
        # Start writing to an output file
        setwd(resultsGLMPath)
        sink(resultFile, append=TRUE)
        print("============Odds Ratio for predictors with p-value > 0.05")
        sink()	# Stop writing to the file	
        for (i in 1:length(significantPredictors_10)) { 
          predictor <- significantPredictors_10[i]
          pvalue <- matrixCoefValues[significantPredictors_10[i],4]
          oddChanges = round(exp(coeffs[significantPredictors_10[i]]),2) #sÃ³ os significativos
          percOddChanges = round((oddChanges - 1)*100,2)	
          if(predictor == "existsCommonSlice"){					
            oddsExistsCommonSlice_10[countOddsExistsCommonSlice_10] <- percOddChanges
            countOddsExistsCommonSlice_10 <- countOddsExistsCommonSlice_10 + 1
          }else if(predictor == "totalCommonSlices"){					
            oddsTotalCommonSlices_10[countOddsTotalCommonSlices_10] <- percOddChanges
            countOddsTotalCommonSlices_10 <- countOddsTotalCommonSlices_10 + 1
          }else if(predictor == "existsCommonPackages"){					
            oddsExistsCommonPackages_10[countOddsExistsCommonPackages_10] <- percOddChanges
            countOddsExistsCommonPackages_10 <- countOddsExistsCommonPackages_10 + 1
          }else if(predictor == "totalCommonPackages"){					
            oddsTotalCommonPackages_10[countOddsTotalCommonPackages_10] <- percOddChanges
            countOddsTotalCommonPackages_10 <- countOddsTotalCommonPackages_10 + 1
          }else if(predictor == "numberOfCommitsGeoAverage"){					
            oddsNumberOfCommitsGeoAverage_10[countOddsNumberOfCommitsGeoAverage_10] <- percOddChanges
            countOddsNumberOfCommitsGeoAverage_10 <- countOddsNumberOfCommitsGeoAverage_10 + 1
          }else if(predictor == "numberOfAuthorsGeoAverage"){					
            oddsNumberOfAuthorsGeoAverage_10[countOddsNumberOfAuthorsGeoAverage_10] <- percOddChanges
            countOddsNumberOfAuthorsGeoAverage_10 <- countOddsNumberOfAuthorsGeoAverage_10 + 1
          }#else if(predictor == "delayIntegrationGeoAverage"){					
          #oddsDelayIntegrationGeoAverage_10[countOddsDelayIntegrationGeoAverage_10] <- percOddChanges
          #countOddsDelayIntegrationGeoAverage_10 <- countOddsDelayIntegrationGeoAverage_10 + 1
          #}else if(predictor == "deltaIntegration"){					
          #oddsDeltaIntegrationSlice_10[countOddsDeltaIntegrationSlice_10] <- percOddChanges
          #countOddsDeltaIntegrationSlice_10 <- countOddsDeltaIntegrationSlice_10 + 1
          #}
          else if(predictor == "numberOfChangedFilesGeoAverage"){					
            oddsNumberOfChangedFilesGeoAverage_10[countOddsNumberOfChangedFilesGeoAverage_10] <- percOddChanges
            countOddsNumberOfChangedFilesGeoAverage_10 <- countOddsNumberOfChangedFilesGeoAverage_10 + 1
          }else if(predictor == "numberOfChangedLinesGeoAverage"){					
            oddsNumberOfChangedLinesGeoAverage_10[countOddsNumberOfChangedLinesGeoAverage_10] <- percOddChanges
            countOddsNumberOfChangedLinesGeoAverage_10 <- countOddsNumberOfChangedLinesGeoAverage_10 + 1
          }else if(predictor == "minimumLifeTimeGeoAverage"){					
            oddsMinimumLifeTimeGeoAverage_10[countOddsMinimumLifeTimeGeoAverage_10] <- percOddChanges
            countOddsMinimumLifeTimeGeoAverage_10 <- countOddsMinimumLifeTimeGeoAverage_10 + 1
          }else if(predictor == "contributionConclusionDelay"){					
            oddsContributionConclusionDelay_10[countOddsContributionConclusionDelay_10] <- percOddChanges
            countOddsContributionConclusionDelay_10 <- countOddsContributionConclusionDelay_10 + 1
          }
          
          #para imprimir em relatÃ³rio texto livre
          print(paste("odds de ",predictor," = ",oddChanges," que representa ",percOddChanges,"% chances de ocorrer conflito"))
          # Start writing to an output file	
          setwd(resultsGLMPath)
          sink(resultFile, append=TRUE)
          print(paste("Predictor = ",predictor,", Odds Ratio = ",oddChanges,", %Odds = ",percOddChanges,", p-value = ",pvalue))
          sink()	# Stop writing to the file	
          
        }#for
        
      } #if
      
      
    } else{
      # Start writing to an output file
      print("after running, there are no significant predictors")	
      # Start writing to an output file	
      setwd(resultsGLMPath)
      sink(resultFile, append=TRUE)
      print("after running, there are no significant predictors")			
      sink()	# Stop writing to the file	
    }
    
  } else { 
    print("NÃ£o hÃ¡ preditores resultantes na lista final")
  }
  #Resumo para imprimir no reltÃ³rio por projeto 
  print("==================RESUMO DADOS AJUSTE MODELO")
  print(paste("AIC = ",aicSample)) 
  print(paste("Deviance of the model = ", devianceSample)) 
  print(paste("Deviance Explained = ", percDevianceExplained)) 
  print(paste("Chi2 = ", chi2Sample)) 
  print(paste("p-value = ",pValueSample))
  # Start writing to an output file	
  setwd(resultsGLMPath)
  sink(resultFile, append=TRUE)
  print("==================Model fit summary")
  print(paste("AIC = ",aicSample)) 
  print(paste("Deviance of the model = ", devianceSample)) 
  print(paste("Deviance Explained = ", percDevianceExplained)) 
  print(paste("Chi2 = ", chi2Sample)) 
  print(paste("p-value = ",pValueSample))
  sink()	# Stop writing to the file	
  
  print("============================================================================================")
  print(paste("=========================FIM DADOS DO PROJETO ",projectName,"======================="))
  print("============================================================================================")
  results<- list(sigPredictors_5 = significantPredictors_5, sigPredictors_10 = significantPredictors_10, percOddsSlices_5 = oddsExistsCommonSlice_5, percOddsTotalCommonSlices_5 = oddsTotalCommonSlices_5, percOddsExistsCommonPackages_5 = oddsExistsCommonPackages_5, percOddsTotalCommonPackages_5 = oddsTotalCommonPackages_5, percOddsCommits_5 = oddsNumberOfCommitsGeoAverage_5, percOddsAuthors_5 = oddsNumberOfAuthorsGeoAverage_5, percOddsFiles_5 = oddsNumberOfChangedFilesGeoAverage_5, percOddsLines_5 = oddsNumberOfChangedLinesGeoAverage_5, percOddsLifeTime_5 = oddsMinimumLifeTimeGeoAverage_5, percOddsContributionConclusionDelay_5 = oddsContributionConclusionDelay_5, percOddsSlices_10 = oddsExistsCommonSlice_10, percOddsTotalCommonSlices_10 = oddsTotalCommonSlices_10, percOddsExistsCommonPackages_10 = oddsExistsCommonPackages_10, percOddsTotalCommonPackages_10 = oddsTotalCommonPackages_10, percOddsCommits_10 = oddsNumberOfCommitsGeoAverage_10, percOddsAuthors_10 = oddsNumberOfAuthorsGeoAverage_10, percOddsFiles_10 = oddsNumberOfChangedFilesGeoAverage_10, percOddsLines_10 = oddsNumberOfChangedLinesGeoAverage_10, percOddsLifeTime_10 = oddsMinimumLifeTimeGeoAverage_10, percOddsContributionConclusionDelay_10 = oddsContributionConclusionDelay_10, mergesFreq = mergesFreq)
  return(results)
  rm(list = ls()) #remove Objects from a Specified Environment. 
  
} 

VIF_Analysis <- function(fileName, responseVariable, predictorsVariablesList) {
  
  library(aod) 
  dataSample<- ""
  if(is.character(fileName)){
    setwd(variablesCSVPath)
    dataSample = read.csv(fileName, header=T, sep =",")#[ ,c("isConflicting","existsCommonSlice", "numberOfCommitsGeoAverage", "numberOfAuthorsGeoAverage", "delayIntegrationGeoAverage", "deltaIntegration", "minimumLifeTimeGeoAverage", "numberOfChangedFilesGeoAverage", "numberOfChangedLinesGeoAverage")]
  }else{
    dataSample = fileName
  }
  
  
  predictorsList <- predictorsVariablesList #c("isConflicting","existsCommonSlice", "numberOfCommitsGeoAverage", "numberOfAuthorsGeoAverage", "delayIntegrationGeoAverage", "deltaIntegration", "minimumLifeTimeGeoAverage", "numberOfChangedFilesGeoAverage", "numberOfChangedLinesGeoAverage")
  response<- responseVariable
  predictors <- paste(predictorsList, collapse = '+')
  variables <- formula(paste(response, '~', predictors))
  model = glm(variables, family = binomial(logit), data = dataSample)
  print("=============VERIFICANDO SE HÃ PREDITORES SEM VALOR PARA O ESTIMATE")
  coefs <- coefficients(model)
  print(coefs) #debbuging
  coefsExcluded <-c()
  countCoefsExcluded <-1
  
  for (i in 1:length(coefs)){
    value <- paste(coefs[i])
    if (value=="NA"){
      coefsExcluded[countCoefsExcluded]<- names(coefs[i])
      print(paste("VIF_Analysis----coefsExcluded[",i,"] = ",coefsExcluded[countCoefsExcluded])) #debbuging
      countCoefsExcluded <- countCoefsExcluded + 1
    }
  }
  
  if (length(coefsExcluded)>0){
    tmp <- c()
    for (i in 1:length(coefsExcluded)){
      for (j in 1:length(predictorsList)){
        print(coefsExcluded[i] == paste(predictorsList[j])) #debbuging
        if (coefsExcluded[i] == paste(predictorsList[j])){
          tmp <- predictorsList[-j]					
        }
      }
    }
    
    if (length(tmp) > 1){
      return (VIF_Analysis(fileName, response, tmp))
    }else{
      predictorsList <- tmp
      return (predictorsList)
    }
    
  }
  
  print(paste("predictorsList antes do vif = ",paste(predictorsList,collapse=","))) #debbuging 
  
  if (length(predictorsList) > 1){
    predictorToExclude <- checkVIF(model)	
    if (predictorToExclude!=""){
      tmp<-c()
      print(paste("predictor a ser excluÃ�do pos vif= ", predictorToExclude))
      for(i in 1: length(predictorsList)){
        if(predictorToExclude==predictorsList[i]){
          tmp <- predictorsList[-i]
          return (VIF_Analysis(fileName, response, tmp))
        }	
      }
    }else {	
      print("===============================LISTA FINAL COM PREDITORES QUE DEVEM SER EXECUTADOS NA GLM ==========================")
      print(paste("os ", length(predictorsList), " seguintes preditores devem ser mantidos = ", paste(predictorsList, collapse=",")))
      print("==================================================================================================================")
      return (predictorsList)
    }
  }
  return (predictorsList)
}


checkVIF <- function(model){
  
  library(car)
  vifValues <- vif(model)
  print(vifValues) #debbuging
  predictor <- ""
  predictorVIF <- 0
  tmpVIF <-0
  
  for (i in 1:length(vifValues)){
    if (vifValues[i] > 5) {
      if(tmpVIF < vifValues[i]){
        print(paste("entrou em ", names(vifValues[i])))
        predictor <- names(vifValues[i])
        predictorVIF<- vifValues[i]
        tmpVIF <- predictorVIF
      }	
      
    }
  }
  
  print(paste("ANTES DE SAIR DO CHECKVIF = HÃ¡ predictor para ser removido? (lista != vazio)",predictor !="" )) #debugging
  
  return (predictor)
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


##############################################################################
##Script para rodar N amostras de uma sÃ³ vez e resumo consolidado
#################################################################################


analysisGLM<- function(fileName, response, predictorsList, selectModel, usesVIF){
  
  #unlink(resultFile, recursive = FALSE, force = FALSE)
  
  projects <- readConfigProperties(fileName)
  
  significantPredictors_5 <- c()
  countSgnificantPredictors_5 <-1
  
  significantPredictors_10 <- c()   
  countSignificantPredictors_10 <-1
  
  oddsExistsCommonSlice_5 <- c() 
  oddsTotalCommonSlices_5 <- c()
  oddsExistsCommonPackages_5 <- c()
  oddsTotalCommonPackages_5 <- c()
  oddsNumberOfCommitsGeoAverage_5 <- c()
  oddsNumberOfAuthorsGeoAverage_5 <- c()
  oddsNumberOfChangedFilesGeoAverage_5 <- c()
  oddsNumberOfChangedLinesGeoAverage_5 <- c()	
  #oddsDelayIntegrationGeoAverage_5 <- c() #not used anymore
  #oddsDeltaIntegrationSlice_5 <- c() #not used anymore
  oddsMinimumLifeTimeGeoAverage_5 <- c()
  oddsContributionConclusionDelay_5 <- c()
  
  countOddsExistsCommonSlice_5 <- 1 
  countOddsTotalCommonSlices_5 <- 1
  countOddsExistsCommonPackages_5 <- 1
  countOddsTotalCommonPackages_5 <- 1
  countOddsNumberOfCommitsGeoAverage_5 <- 1
  countOddsNumberOfAuthorsGeoAverage_5 <- 1
  countOddsNumberOfChangedFilesGeoAverage_5 <- 1
  countOddsNumberOfChangedLinesGeoAverage_5 <- 1
  #countOddsDelayIntegrationGeoAverage_5 <- 1 #not used anymore
  #countOddsDeltaIntegrationSlice_5 <- 1 # not used anymore
  countOddsMinimumLifeTimeGeoAverage_5 <- 1
  countOddsContributionConclusionDelay_5 <- 1
  
  
  oddsExistsCommonSlice_10 <- c() 
  oddsTotalCommonSlices_10 <- c()
  oddsExistsCommonPackages_10 <- c()
  oddsTotalCommonPackages_10 <- c()
  oddsNumberOfCommitsGeoAverage_10 <- c()
  oddsNumberOfAuthorsGeoAverage_10 <- c()
  oddsNumberOfChangedFilesGeoAverage_10 <- c()
  oddsNumberOfChangedLinesGeoAverage_10 <- c()	
  #oddsDelayIntegrationGeoAverage_10 <- c() #not used anymore
  #oddsDeltaIntegrationSlice_10 <- c() #not used anymore
  oddsMinimumLifeTimeGeoAverage_10 <- c()
  oddsContributionConclusionDelay_10 <- c()
  
  countOddsExistsCommonSlice_10 <- 1 
  countOddsTotalCommonSlices_10 <- 1
  countOddsExistsCommonPackages_10 <- 1
  countOddsTotalCommonPackages_10 <- 1
  countOddsNumberOfCommitsGeoAverage_10 <- 1
  countOddsNumberOfAuthorsGeoAverage_10 <- 1
  countOddsNumberOfChangedFilesGeoAverage_10 <- 1
  countOddsNumberOfChangedLinesGeoAverage_10 <- 1	
  #countOddsDelayIntegrationGeoAverage_10 <- 1 #not used anymore
  #countOddsDeltaIntegrationSlice_10 <- 1 #not used anymore
  countOddsMinimumLifeTimeGeoAverage_10 <- 1
  countOddsContributionConclusionDelay_10 <- 1
  
  totalMerges <- c()
  cleanMergesFreq <- c()
  conflictingMergesFreq <- c()
  
  for (i in 1:length(projects)) {
    response <- "isConflicting" 
    resultsGLM = multipleGLM(projects[i],response, predictorsList, selectModel, usesVIF )
    
    totalMerges[i] <- resultsGLM$mergesFreq$merges
    cleanMergesFreq[i] <- resultsGLM$mergesFreq$pClean
    conflictingMergesFreq[i] <- resultsGLM$mergesFreq$pConflicting
    
    if (length(resultsGLM$sigPredictors_5) > 0){
      for(i in 1:length(resultsGLM$sigPredictors_5)){
        significantPredictors_5[countSgnificantPredictors_5] <- resultsGLM$sigPredictors_5[i]
        countSgnificantPredictors_5 <- countSgnificantPredictors_5 + 1
      }
    }
    if (length(resultsGLM$sigPredictors_10) > 0){
      for(i in 1:length(resultsGLM$sigPredictors_10)){
        significantPredictors_10[countSignificantPredictors_10] <- resultsGLM$sigPredictors_10[i]
        countSignificantPredictors_10 <- countSignificantPredictors_10 + 1
      }
    }
    
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
    #if (length(resultsGLM$percOddsDelay_5) > 0){
    #  for(i in 1:length(resultsGLM$percOddsDelay_5)){
    #    oddsDelayIntegrationGeoAverage_5[countOddsDelayIntegrationGeoAverage_5] <- resultsGLM$percOddsDelay_5[i]
    #    countOddsDelayIntegrationGeoAverage_5 <- countOddsDelayIntegrationGeoAverage_5 + 1
    #  }
    #}		
    #if (length(resultsGLM$percOddsDelta_5) > 0){
    #  for(i in 1:length(resultsGLM$percOddsDelta_5)){
    #    oddsDeltaIntegrationSlice_5[countOddsDeltaIntegrationSlice_5] <- resultsGLM$percOddsDelta_5[i]
    #    countOddsDeltaIntegrationSlice_5 <- countOddsDeltaIntegrationSlice_5 + 1
    #  }
    #}		
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
    if (length(resultsGLM$percOddsLifeTime_5) > 0){
      for(i in 1:length(resultsGLM$percOddsLifeTime_5)){
        oddsMinimumLifeTimeGeoAverage_5[countOddsMinimumLifeTimeGeoAverage_5] <- resultsGLM$percOddsLifeTime_5
        countOddsMinimumLifeTimeGeoAverage_5 <- countOddsMinimumLifeTimeGeoAverage_5 + 1
      }
    }			
    if (length(resultsGLM$percOddsContributionConclusionDelay_5) > 0){
      for(i in 1:length(resultsGLM$percOddsContributionConclusionDelay_5)){
        oddsContributionConclusionDelay_5[countOddsContributionConclusionDelay_5] <- resultsGLM$percOddsContributionConclusionDelay_5
        countOddsContributionConclusionDelay_5 <- countOddsContributionConclusionDelay_5 + 1
      }
    }		
    
    
    if (length(resultsGLM$percOddsSlices_10) > 0){
      for(i in 1:length(resultsGLM$percOddsSlices_10)){
        oddsExistsCommonSlice_10[countOddsExistsCommonSlice_10] <- resultsGLM$percOddsSlices_10[i]
        countOddsExistsCommonSlice_10 <- countOddsExistsCommonSlice_10 + 1
      }
    }
    if (length(resultsGLM$percOddsTotalCommonSlices_10) > 0){
      for(i in 1:length(resultsGLM$percOddsTotalCommonSlices_10)){
        oddsTotalCommonSlices_10[countOddsTotalCommonSlices_10] <- resultsGLM$percOddsTotalCommonSlices_10[i]
        countOddsTotalCommonSlices_10 <- countOddsTotalCommonSlices_10 + 1
      }
    }
    if (length(resultsGLM$percOddsExistsCommonPackages_10) > 0){
      for(i in 1:length(resultsGLM$percOddsExistsCommonPackages_10)){
        oddsExistsCommonPackages_10[countOddsExistsCommonPackages_10] <- resultsGLM$percOddsExistsCommonPackages_10[i]
        countOddsExistsCommonPackages_10 <- countOddsExistsCommonPackages_10 + 1
      }
    }
    if (length(resultsGLM$percOddsTotalCommonPackages_10) > 0){
      for(i in 1:length(resultsGLM$percOddsTotalCommonPackages_10)){
        oddsTotalCommonPackages_10[countOddsTotalCommonPackages_10] <- resultsGLM$percOddsTotalCommonPackages_10[i]
        countOddsTotalCommonPackages_10 <- countOddsTotalCommonPackages_10 + 1
      }
    }
    if (length(resultsGLM$percOddsCommits_10) > 0){
      for(i in 1:length(resultsGLM$percOddsCommits_10)){
        oddsNumberOfCommitsGeoAverage_10[countOddsNumberOfCommitsGeoAverage_10] <- resultsGLM$percOddsCommits_10[i]
        countOddsNumberOfCommitsGeoAverage_10 <- countOddsNumberOfCommitsGeoAverage_10 + 1
      }
    }		
    if (length(resultsGLM$percOddsAuthors_10) > 0){
      for(i in 1:length(resultsGLM$percOddsAuthors_10)){
        oddsNumberOfAuthorsGeoAverage_10[countOddsNumberOfAuthorsGeoAverage_10] <- resultsGLM$percOddsAuthors_10[i]
        countOddsNumberOfAuthorsGeoAverage_10 <- countOddsNumberOfAuthorsGeoAverage_10 + 1
      }
    }		
    
    if (length(resultsGLM$percOddsFiles_10) > 0){
      for(i in 1:length(resultsGLM$percOddsFiles_10)){
        oddsNumberOfChangedFilesGeoAverage_10[countOddsNumberOfChangedFilesGeoAverage_10] <- resultsGLM$percOddsFiles_10
        countOddsNumberOfChangedFilesGeoAverage_10 <- countOddsNumberOfChangedFilesGeoAverage_10 + 1
      }
    }
    if (length(resultsGLM$percOddsLines_10) > 0){
      for(i in 1:length(resultsGLM$percOddsLines_10)){
        oddsNumberOfChangedLinesGeoAverage_10[countOddsNumberOfChangedLinesGeoAverage_10] <- resultsGLM$percOddsLines_10
        countOddsNumberOfChangedLinesGeoAverage_10 <- countOddsNumberOfChangedLinesGeoAverage_10 + 1
      }
    }		
    if (length(resultsGLM$percOddsLifeTime_10) > 0){
      for(i in 1:length(resultsGLM$percOddsLifeTime_10)){
        oddsMinimumLifeTimeGeoAverage_10[countOddsMinimumLifeTimeGeoAverage_10] <- resultsGLM$percOddsLifeTime_10
        countOddsMinimumLifeTimeGeoAverage_10 <- countOddsMinimumLifeTimeGeoAverage_10 + 1
      }
    }			
    if (length(resultsGLM$percOddsContributionConclusionDelay_10) > 0){
      for(i in 1:length(resultsGLM$percOddsContributionConclusionDelay_10)){
        oddsContributionConclusionDelay_10[countOddsContributionConclusionDelay_10] <- resultsGLM$percOddsContributionConclusionDelay_10
        countOddsContributionConclusionDelay_10 <- countOddsContributionConclusionDelay_10 + 1
      }
    }	
  }#for
  
  
  # Start writing to an output file		
  setwd(resultsGLMPath)
  sink(resultFile, append=TRUE)
  
  #print("==============================================================================================================")
  #print("======================================START SUMMARY RESULTS===================================================")
  #print("==============================================================================================================")
  
  #print(paste("================Total Evaluated Projects = ",length(projects)))
  #print(paste("Merge scenarios range from ", totalMerges[which.min(totalMerges)]," to ",totalMerges[which.max(totalMerges)]," ::: Mean = ",round(mean(totalMerges),2),"; Meadian = ", round(median(totalMerges),2),"; Std = ",round(sd(totalMerges),2)))
  #print(paste("Clean scenarios frequency ranges from ", cleanMergesFreq[which.min(cleanMergesFreq)],"% to ",cleanMergesFreq[which.max(cleanMergesFreq)],"% ::: Mean = ",round(mean(cleanMergesFreq),2),"; Meadian = ", round(median(cleanMergesFreq),2),"; Std = ",round(sd(cleanMergesFreq),2)))
  #print(paste("Conflicting scenarios frequency ranges from ", conflictingMergesFreq[which.min(conflictingMergesFreq)],"% to ",conflictingMergesFreq[which.max(conflictingMergesFreq)],"% ::: Mean = ",round(mean(conflictingMergesFreq),2),"; Meadian = ", round(median(conflictingMergesFreq),2),"; Std = ",round(sd(conflictingMergesFreq),2)))
  
  #get the ocorrence of significant predictors with 5%
  #print("================Summary of resulting predictors considering p-value <= 0.05")
  #listSignificantPredictors(significantPredictors_5, projects)
  
  #print("================Odds Ratio Range considering predictors with p-value <= 0.05")
  #listPercentualOddsPredictors(oddsExistsCommonSlice_5, "existsCommonSlice")
  #listPercentualOddsPredictors(oddsTotalCommonSlices_5, "totalCommonSlices")
  #listPercentualOddsPredictors(oddsExistsCommonPackages_5, "existsCommonPackages")
  #listPercentualOddsPredictors(oddsTotalCommonPackages_5, "totalCommonPackages")
  #listPercentualOddsPredictors(oddsNumberOfCommitsGeoAverage_5, "numberOfCommitsGeoAverage")
  #listPercentualOddsPredictors(oddsNumberOfAuthorsGeoAverage_5, "numberOfAuthorsGeoAverage")
  #listPercentualOddsPredictors(oddsNumberOfChangedFilesGeoAverage_5, "numberOfChangedFilesGeoAverage")
  #listPercentualOddsPredictors(oddsNumberOfChangedLinesGeoAverage_5, "numberOfChangedLinesGeoAverage")
  ###listPercentualOddsPredictors(oddsDelayIntegrationGeoAverage_5, "delayIntegrationGeoAverage") #not used anymore
  ###listPercentualOddsPredictors(oddsDeltaIntegrationSlice_5, "deltaIntegration") #not used anymore
  #listPercentualOddsPredictors(oddsMinimumLifeTimeGeoAverage_5, "minimumLifeTimeGeoAverage")
  #listPercentualOddsPredictors(oddsContributionConclusionDelay_5, "contributionConclusionDelay")
  
  #print("================Summary of resulting predictors considering p-value > 0.05")
  #listSignificantPredictors(significantPredictors_10, projects)
  
  #print("================Odds Ratio Range considering predictors with p-value > 0.05")
  #listPercentualOddsPredictors(oddsExistsCommonSlice_10, "existsCommonSlice")
  #listPercentualOddsPredictors(oddsTotalCommonSlices_10, "totalCommonSlices")
  #listPercentualOddsPredictors(oddsExistsCommonPackages_10, "existsCommonPackages")
  #listPercentualOddsPredictors(oddsTotalCommonPackages_10, "totalCommonPackages")
  #listPercentualOddsPredictors(oddsNumberOfCommitsGeoAverage_10, "numberOfCommitsGeoAverage")
  #listPercentualOddsPredictors(oddsNumberOfAuthorsGeoAverage_10, "numberOfAuthorsGeoAverage")
  #listPercentualOddsPredictors(oddsNumberOfChangedFilesGeoAverage_10, "numberOfChangedFilesGeoAverage")
  #listPercentualOddsPredictors(oddsNumberOfChangedLinesGeoAverage_10, "numberOfChangedLinesGeoAverage")
  ###listPercentualOddsPredictors(oddsDelayIntegrationGeoAverage_10, "delayIntegrationGeoAverage") #not used anymore
  ###listPercentualOddsPredictors(oddsDeltaIntegrationSlice_10, "deltaIntegration") #not used anymore
  #listPercentualOddsPredictors(oddsMinimumLifeTimeGeoAverage_10, "minimumLifeTimeGeoAverage")
  #listPercentualOddsPredictors(oddsContributionConclusionDelay_10, "contributionConclusionDelay")
  
  
  sink()	# Stop writing to the file	
  
  setwd(rAnalysisPath)
}


#to execute your model, alter the variables list of the predictorsList parameter below with the desired set.
response <- "isConflicting" 
predictorsList <- c("existsCommonSlice","totalCommonPackages","existsCommonPackages", "numberOfCommitsGeoAverage", "contributionConclusionDelay")
analysisGLM("sampleProjectsList.csv", response, predictorsList, 0, "true")


