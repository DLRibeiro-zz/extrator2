require 'require_all'
require_all './Repository'

class GitProject

	def initialize(project, localPath, pathResults)
		@projectName = project.split("/")[1].gsub("\"", "")
		@projectFullName = project.gsub("/","_")
		@pathClone = cloneProjectLocally(project, localPath)
		@mergeScenarios = Array.new
		getMergesScenariosByProject(localPath, pathResults)
	end


	def getPathClone()
		@pathClone
	end

	def getProjectName()
		@projectName
	end

	def getMergeScenarios()
		@mergeScenarios
	end

	def getProjectFullName()
		@projectFullName
	end

	

	def cloneProjectLocally(project, localPath)
		Dir.chdir localPath
		if File.directory?("localProject")
			#delete = %x(rd /s /q localProject) #windows
			delete = %x(rm -rf localProject) # lixun usar rm -rf localProject
			puts "local was deleted before clonning" #debugging...
		end
		clone = %x(git clone https://github.com/#{project} localProject)
		Dir.chdir "localProject"
		return Dir.pwd
	end

	def deleteProject()
		Dir.chdir getLocalPath()
		#delete = %x(rd /s /q localProject) #windows
		delete = %x(rm -rf localProject) #linux usar: rm -rf localProject
	end

	def getMergesScenariosByProject(localPath, pathResults)
		Dir.chdir getPathClone()
		merges = %x(git log --pretty=format:'%H' --merges)
		merges.each_line do |mergeScenario|
			parents = getParentsMerge(mergeScenario.gsub("\n","").gsub("\'",""))
			ancestor = %x(git merge-base #{parents[0]} #{parents[1]}).gsub("\r","").gsub("\n","")
			# Remove fastfoward before adding to list (due to pull request or branch, merge fastfoward merges always have 2 parents in git log)
			if (!parents[0].eql? ancestor and !parents[1].eql? ancestor) #fastfoward (pull request)
				mergeScenarioObj = MergeScenario.new(mergeScenario.gsub("\n", "").gsub("\'", ""), parents[0], parents[1], ancestor)
				@mergeScenarios.push(mergeScenarioObj)
			end
		end

		#generate summary of mergeScenario liste
     totalMerges = merges.split("\n").length
		 totalFastFowardMerges = totalMerges - getMergeScenarios.length
		 puts "#{getProjectName}  has totalMerges = #{totalMerges}: fastFowardMerges #{totalFastFowardMerges} and otherMerges #{getMergeScenarios.length}"
		File.open(localPath+pathResults+"Summary_MergesByProject.csv", 'a') do |f2|
			if (File.size(localPath+pathResults+"Summary_MergesByProject.csv") == 0)
				f2.puts "project,totalMerges,totalFastFowardMerges,totalOtherMerges"
			end
			# use "\n" para duas linhas de texto
			f2.puts "#{getProjectName},#{totalMerges},#{totalFastFowardMerges},#{getMergeScenarios.length}"
		end
	end

	
	def getParentsMerge(commit)
	    parentsCommit = Array.new
		commitParent = %x(git cat-file -p #{commit})
		commitParent.each_line do |line|
			if(line.include?('author'))
				break
			end
			if(line.include?('parent'))
				commitSHA = line.partition('parent ').last.gsub('\n','').gsub(' ','').gsub('\r','')
				parentsCommit.push(commitSHA[0..39].to_s)
			end
		end

		if (parentsCommit.size > 1)
			return parentsCommit
		else
			return nil
		end
	end

	def generateMergeScenarioList(projectName, localPath, pathResults)

		dataList = []
		mergeCommitParents = getMergeScenarios
		mergeCommitParents.each do |mergeParents|
				mergeCommitID = mergeParents.getMergeCommit()
				left = mergeParents.getLeft()
				right = mergeParents.getRight()
				ancestor = mergeParents.getAncestor()
				mergeConflictsData = getMergeInfoAboutConflicts(mergeCommitID, left, right).split(",")
				mergeContributionsData = getMergeConributions(mergeCommitID, left, right, ancestor).split(",")

				mergeCommitId = mergeCommitID
				isMergeConflicting = mergeConflictsData[0]
				filesConflictants = mergeConflictsData[1]
				parent1Id = left
				parent1Files = mergeContributionsData[0]
				parent2Id = right
				parent2Files = mergeContributionsData[1]
				ancestorId = ancestor
				numberOfConflicts = mergeConflictsData[2]
				data = mergeCommitId+","+isMergeConflicting+","+filesConflictants+","+parent1Id+","+parent1Files+","+parent2Id+","+parent2Files+","+ancestorId+","+numberOfConflicts
				dataList.push(data.gsub("\n", ""))

		end
		count = 0 #debugging
		File.open(localPath+pathResults+projectName+"_MergeScenarioList.csv", 'w') do |file|
			file.puts "mergeCommitId,isMergeConflicting,filesConflictants,parent1Id,parent1Files,parent2Id,parent2Files,ancestorId,numberOfConflicts"

			dataList.each do |dataMerge|
				file.puts "#{dataMerge}"
				count+=1
			end
			puts "Ending execution: Projeto #{projectName} - Merges = #{count}" #debugging...
			
			#generate seleted project list for input in modularity extractor step
			File.open(localPath+pathResults+"projectList.csv", 'a') do |f2|
				# use "\n" para duas linhas de texto
				f2.puts "#{getProjectName}"
			end
		end

		return dataList

	end

	#minTotalMerges é o número mínimo de merges que o projeto deve ter, a partir do qual será extraída uma amostra de tamanho
	#sampleSize. Ex: caso a decisão seja que todos os os projetos selecionados tenham no mínimo 300 merges e
	# que serão extraídos aleatórioamente 70% dos merges de cada projeto. Nesse caso minTotalMerges = 300 e sampleSize = 210
	#minTotalMerges usado para garantir que nenhum projeto será usdo sem o tamanho mínimo desejado para extração aleatoria
	def generateRandomizedMergeScenarioList(projectName, localPath, pathResults, dataList, minTotalMerges, sampleSize)

		#generate randomList
		if (dataList.length >= minTotalMerges.to_i) #mínimo para pegar 50% a 70%
			randomDataList = getRandomList(dataList,sampleSize.to_i)
			File.open(localPath+pathResults+projectName+"_MergeScenarioList.csv", 'w') do |file|
				file.puts "mergeCommitId,isMergeConflicting,filesConflictants,parent1Id,parent1Files,parent2Id,parent2Files,ancestorId,numberOfConflicts"

				randomDataList.each do |randomDataMerge|
					file.puts "#{randomDataMerge}"
				end
				puts "Ending generate random file for #{projectName} project - Merges = #{randomDataList.length}" #debugging...

				#generate seleted project list for input in modularity extractor step
				File.open(localPath+pathResults+"projectList.csv", 'a') do |f2|
					# use "\n" para duas linhas de texto
					f2.puts "#{getProjectName}"
				end
			end
			#generate summary of random mergeScenario list
			totalMerges = dataList.length
			totalRandomMerges = randomDataList.length
			File.open(localPath+pathResults+"Summary_MergesByProject.csv", 'a') do |f2|
				if (File.size(localPath+pathResults+"Summary_MergesByProject.csv") == 0)
					f2.puts "project,totalMerges,totalRandomMerges"
				end
				# use "\n" para duas linhas de texto
				f2.puts "#{getProjectName},#{totalMerges},#{totalRandomMerges}"
			end
		else
			#projects with less merges than the minTotalMerges informed
			File.open(localPath+pathResults+"Summary_ExcludedProjectsFromRandomSample.csv", 'a') do |f2|
				# use "\n" para duas linhas de texto
				f2.puts "#{getProjectName}"
			end
		end
	end


	def getRandomList(dataList, sampleSize)
		#generate randomList
		randomList = dataList.sample(sampleSize)
		conflictingMerge = false
		cleanMerge = false
		randomList.each do |random|
			element =  random.split(",")
			if (element[1].eql? "true")
				conflictingMerge = true
			else
				cleanMerge = true
			end
		end
		if (!conflictingMerge.eql?(true) and !cleanMerge.eql?(true))
			return getRandomList(dataList, sampleSize)
		else
			return randomList
		end
	end

	def getMergeInfoAboutConflicts(mergeCommitID, left, right)
		Dir.chdir getPathClone
		%x(git reset --hard #{left})
		%x(git clean -f)
		%x(git checkout -b new #{right})
		%x(git checkout master)
		%x(git merge new)

		conflictingFiles = %x(git diff --name-only --diff-filter=U).split("\n")

		isMergeConflicting = false

		#get response variable "conflict occurrence"
		if (conflictingFiles.length > 0) # conflict
    	isMergeConflicting = true
		end

		totalConflicts = 0
		conflictingFiles.each do |conflictingFile|
			x = '=======' # pode usar outros marcadores de conflitos ou com regexp..usei esse por simplicidade
			parcialTotal = 0
			parcialTmp = %x(git grep -c #{x} #{conflictingFile})#.split(":")[1].gsub("\n","").to_i
			if (parcialTmp.length ==0)
				parcialTotal = 1
			else
				parcialTotal = %x(git grep -c #{x} #{conflictingFile}).split(":")[1].gsub("\n","").to_i
			end
			totalConflicts = totalConflicts + parcialTotal
		end
		dataInfoMerges = isMergeConflicting.to_s+","+conflictingFiles.to_s.gsub("\"","").gsub(",","@")+","+totalConflicts.to_s #usado para não considar cada elemento dalista como se forssse um item separado da linha

		#delete without merge
		%x(git branch -D new)

		return dataInfoMerges

	end

	def getMergeConributions(mergeCommitID, left, right, ancestor)
		Dir.chdir getPathClone
		#use --name-status instead of --name-only if you want to see the status (i.e., deleted (D), added (D), and modified (M))
		leftFiles = %x(git diff --name-only #{left} ^#{ancestor}).split("\n").uniq #uniq isn't actually necessary here
		rightFiles = %x(git diff --name-only #{right} ^#{ancestor}).split("\n").uniq #uniq isn't actually necessary here
		mergeContributions = leftFiles.to_s.gsub("\"","").gsub(",","@")+","+rightFiles.to_s.gsub("\"","").gsub(",","@")
		return mergeContributions
	end


end
