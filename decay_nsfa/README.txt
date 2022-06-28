% Man Ho Wong, m.wong@pitt.edu
University of Pittsburgh, 2022-04-02

---------------------------------------------------
"demoData/" contains the data for testing the scripts.

"scripts/" contains:

- nsfa.m : core function to run NSFA (user most likely won't need to edit this)

- runNSFA.m : a script template which user can use to perform NSFA on one recording or multiple recordings in a folder. This script calls the function "nsfa.m". For more info, see "runNSFA.m".

---------------------------------------------------
Files needed to run NSFA: 

1. Mini events file* (.txt)
See examples in the folder "miniEvents_demo/"

2. aligned traces* (.txt)
Aligned by MiniAnalysis program. Both average and individual traces should be included.
See examples in the folder "alignedTraces_demo/"

*Both files must have IDENTICAL name so the script can match them!

---------------------------------------------------
How to run batch analysis on demo data:

- "runNSFA.m" has already been configured for the demo data. Just open the script and click "Run".

- If MATLAB says the script is not found in the current folder, click "Change Folder".

---------------------------------------------------
Where to find the analysis results:

- Figures and analysis reports will be stored in an user-specified folder. See "runNSFA.m".

- Note: If user chooses an existing folder as the folder to store the results, figures and reports from the previous analysis will be overwritten if they have the same file names.

---------------------------------------------------
NSFA reference:
https://doi-org.pitt.idm.oclc.org/10.1038/nprot.2007.47
