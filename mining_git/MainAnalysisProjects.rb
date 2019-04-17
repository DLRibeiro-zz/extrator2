require 'require_all'
require_all './Repository'

class MainAnalysisProjects

	def initialize(loginUser, passwordUser, pathResultsAllMerges, pathResultsRandomizedMerges, minTotalMerges, sampleSize, projectsList)
		@loginUser = loginUser
		@passwordUser = passwordUser
		@pathResultsAllMerges = pathResultsAllMerges
		@pathResultsRandomizedMerges = pathResultsRandomizedMerges
		@minTotalMerges = minTotalMerges
		@sampleSize = sampleSize
		@localPath = Dir.pwd
		Dir.chdir getLocalPath
		@projectsList = projectsList

	end

	def getLocalPath()
		@localPath
	end

	def getLoginUser()
		@loginUser
	end

	def getPasswordUser()
		@passwordUser
	end

	def getPathResultsAllMerges()
		@pathResultsAllMerges
	end

	def getPathResultsRandomizedMerges()
		@pathResultsRandomizedMerges
	end

	def getMinTotalMerges()
		@minTotalMerges
	end

	def getSampleSize()
		@sampleSize
	end

	def getProjectsList()
		@projectsList
	end

	def printStartAnalysis()
#		puts "*************************************"
#		puts "-------------------------------------"
#		puts "####### START COMMITS SEARCH #######"
#		puts "-------------------------------------"
#		puts "*************************************"
	end

	def printProjectInformation (index, project)
#		puts "Project [#{index}]: #{project}"
	end

	def printFinishAnalysis()
#		puts "*************************************"
#		puts "-------------------------------------"
#		puts "####### FINISH COMMITS SEARCH #######"
#		puts "-------------------------------------"
#		puts "*************************************"
	end

	def runAnalysis()
		printStartAnalysis()
		index = 1
		@projectsList.each do |project|
			printProjectInformation(index, project)
			mainGitProject = GitProject.new(project, getLocalPath, @pathResultsAllMerges)
			# projectName = mainGitProject.getProjectName()
			projectName = mainGitProject.getProjectFullName()
			puts "projectName = #{projectName}"		#debugging...
			allMerges = mainGitProject.generateMergeScenarioList(projectName,getLocalPath, getPathResultsAllMerges)
			mainGitProject.generateRandomizedMergeScenarioList(projectName, getLocalPath, getPathResultsRandomizedMerges, allMerges, getMinTotalMerges, getSampleSize)

			index += 1
		end
		printFinishAnalysis()
	end

end

parameters = []
File.open("properties", "r") do |text|
	indexLine = 0
	text.each_line do |line|
		parameters[indexLine] = line[/\<(.*?)\>/, 1]
		indexLine += 1
	end
end

projectsList = []
File.open("projectsList", "r") do |text|
	indexLine = 0
	text.each_line do |line|
		projectsList[indexLine] = line[/\"(.*?)\"/, 1]
		indexLine += 1
	end
end

actualPath = Dir.pwd
puts "actualPath = #{actualPath}"
project = MainAnalysisProjects.new(parameters[0], parameters[1], parameters[2], parameters[3], parameters[4], parameters[5], projectsList)

#debugging...
#puts "Project List[#{project.getProjectsList()}]"
#puts "Local Project[#{project.getLocalPath()}]" #raiz do rpojeto
#puts "Login User[#{project.getLoginUser()}]"
#puts "Password User[#{project.getPasswordUser()}]"
#puts "Path Resuts[#{project.getPathResults()}]"
# end debugging...

project.runAnalysis()

