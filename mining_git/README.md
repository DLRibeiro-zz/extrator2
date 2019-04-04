# mining_git

The mining script retrieves a list of merge commits and their parents. Then reproduces the merge scenario and check whether the merge resulted in conflicts, collect a list of conflicting files list, and compute the number of conflicts. Subsequently, it extracts the list of file names changed
(edited, added, or removed) by all revisions between a parent (left or right) and a base revision of a merge scenario. The changes associated with these files is what constitutes a contribution. 

To run the mining script:

1) Configure the projectsList file: this file should contain all projects selected to compose the sample. Thus, each line of this file should be set with a project identifier by using the following pattern:  "loginUser1/projectName1". For instance, this identifier represents the git repository located on https://github.com/loginUser1/projectName1.
2) Run the MainAnalysisProjects.rb script: ruby MainAnalysisProjects.rb

As output, this script will generate for each project that composes the sample, a file named  xx_MergeScenarioList.csv (xx means the project (s) name (s) used to compose the sample), with the following columns: 

- mergeCommitId: merge commit hash
- isMergeConflicting: true or false
- conflictingFiles: a list of the files with at least one conflict after merge replay
- leftId:  left parent hash
- leftFiles: Left contribution
- rigthId: left parent hash
- rightFiles: right contribution
- ancestorId: the common ancestor hash
- numberOfConflicts: the total number of conflict after merge replay
