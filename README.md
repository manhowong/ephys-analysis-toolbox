# Ephys Analysis Toolbox

Man Ho Wong  
Xu Lab, Department of Neuroscience, University of Pittsburgh.  
January, 2023

## Table of contents

1. [Introduction](#1-introduction)
2. [Toolbox contents](#2-toolbox-contents)
3. [Installation](#3-installation)
4. [Usage](#4-usage)
5. [About](#5-about)

# 1. Introduction

Ephys Analysis Toolbox is an open-source MATLAB toolbox for batch processing of postsynaptic current (PSC) data. The Toolbox is organized into three modules, each comprises a collection of functions for different analyses:
- `kinetics` : for event decay analysis and non-stationary fluctuation analysis (NSFA).
- `membrane_props` : for passive membrane properties analysis.
- `mini_props` : for mEPSC frequency and amplitude analysis.

The Toolbox also comes with read-to-use templates and demo data. See the [Usage](#4-usage) section for more info.

This toolbox is primarily designed to process miniature EPSC (mEPSC) data, though some functions can also be used to process other types of PSC data if the data format is compatible (for example, you can use it to analyze passive membrane properties of evoked EPSC recordings as long as you can provide the capacitance transient of each sweep).

# 2. Toolbox contents

```
(only top two levels are shown)
./
 |---demo_data/               # Sample recordings for demonstration
 |   |---c_transient/         # Capacitance transient of every sweep
 |   |---event_info/          # Info of every detected event
 |   |---event_trace/         # Trace of every detected event
 |   |---fileIndex.xlsx       # Recording information
 |
 |---functions/               # Functions for building an analysis pipeline
 |   |---common/              # Common functions used by all modules
 |   |---kinetics/            # Module for event decay analysis and NSFA
 |   |---membrane_props/      # Module for passive membrane properties
 |   |---mini_props/          # Module for mEPSC frequency and amplitude
 |
 |---resources/               # Documentation, images, etc.
 |
 |---templates/               # Templates written with this toolbox
 |   |---cleanData.m          # Custom script to clean data
 |   |---pipeline.mlx         # Ready-to-use analysis pipeline
 |   |---runFitDecay.m        # Batch analysis of event decay
 |   |---runFitGroupDist.m    # Batch analysis of decay parameter distribution
 |   |---runMembraneProps.m   # Batch analysis of passive membrane properties
 |   |---runNSFA.m            # Batch Non-stationary Fluctuation Analysis
 |
 |---.gitignore
 |---LICENSE
 |---README.md                # YOU ARE HERE
```
# 3. Installation

## 3.1 Requirements
- MATLAB R2021b. Earlier versions supporting the data type `table` should also work (not tested).
- Required toolboxes  (in MATLAB, go to Home Tab > Add-Ons > Get Add-Ons):
    - Statistics and Machine Learning Toolbox
    - Curve fitting Toolbox (for decay fitting and distribution fitting)
    - Optimization Toolbox (for event CDF fitting)

## 3.2 Installation options

### A. Install the Toolbox via MATLAB Add-On Explorer
1. In MATLAB, go to Home Tab > Add-Ons > Get Add-Ons.
2. Search for 'Ephys Analysis Toolbox'
3. On the homepage of this Toolbox, click Add > Add to MATLAB.

### B. Install the Toolbox by installer
1. Download the installer `EphysAnalysisToolbox.mltbx` [here]() or [here]().
2. Run the installer.

### C. Use the Toolbox directly without installation
1. Download the entire Toolbox package [here]().
2. Add all folders and subfolders to the MATLAB search path every time when you start a new MATLAB session. For example, enter the following command:
   ```
   addpath( genpath('path/to/the/package') ) 
   ```

# 4. Usage

## 4.1 Prepare data

For batch processing, you will need **(A)** the raw data files, and **(B)** a file index which provides infomation for the identification of recordings.

> To get a sense of how the files should look like, check out the [demo data](/demo_data). This dataset was extracted from 10 sample recordings and is ready for analysis. 

### A. Raw data files

Each module requires a specific kind of raw data:
- `kinetics` : Trace of every detected event ([example](\demo_data\event_trace\1.txt))
- `membrane_props` : Capacitance transient of every sweep ([example](\demo_data\c_transient\1.txt))
- `mini_props` : Info of every detected event (e.g. peak time, peak amplitude, etc.) ([example](\demo_data\event_info\1.txt))

See [`prepare_data.md`](resources/prepare_data.md) for ways to extract raw data from recordings and data specifications.

File naming and organization:
- Raw data files should be saved in `.txt` format.
- To associate a raw data file with the recording where its data was extracted from, the file should be named after the recording (e.g. name or ID of the recording file). Therefore, two files should have the identical name if both contain data extracted from the same recording.
- Organize raw data files by the kind of data they contain, for example:

```
raw_data/                 
|---c_transient/           # Capacitance transient of every sweep
|   |---recording1.txt
|   |---recording2.txt
|   |---recording3.txt
|---event_info/            # Info of every detected event
|   |---recording1.txt
|   |---recording2.txt
|   |---recording3.txt
|---event_trace/           # Trace of every detected event
    |---recording1.txt
    |---recording2.txt
    |---recording3.txt
```

### B. File index
To identify the recordings, you need to provide an index containing info about the recordings and save it as a `.xlsx` file. It must contains at least the following three columns (with exact same names):
- `fileName` : FULL file name (must be UNIQUE) e.g. `recording1.txt`.
- `age` : age of animal in days (must be numeric).
- `include` : enter `0` to exclude file from analysis, `1` to include. 

Example of a file index:

| fileName       | mouseID | condition | sex | DOB      | age | include |
|----------------|---------|-----------|-----|----------|-----|---------|
| recording1.txt | 1001    | ctrl      | m   | 01/01/23 | 31  | 1       |
| recording2.txt | 1001    | ctrl      | m   | 01/01/23 | 31  | 1       |
| recording3.txt | 1010    | ctrl      | f   | 01/01/23 | 32  | 1       |

The easiest way to create a file index is probably using [`fileIndex.xlsx`](/demo_data/fileIndex.xlsx) in the `demo_data` folder as a template. 

## 4.2 Run analysis using script templates

In the [`templates`](/templates/) folder, you will find a collection of script templates written with the Toolbox. You can use these templates directly to analyze your data.

- `pipeline.mlx` : This is an analysis pipeline covering all modules of the Toolbox, except that batch processing is not available for some analyses (e.g. NSFA). For those analyses, you may use the templates for batch analysis (see below).
- `runFitDecay.m` : computes the decay parameters of each event in every recording found in a folder.
- `runFitGroupDist.m` :  analyzes the distribution of decay parameters by recording and by experimental group.
- `runMembraneProps.m` :  computes the passive membrane properties of every recording found in a folder.
- `runNSFA.m` :  runs NSFA on every recording found in a folder.
- `cleanData.m` : cleans up data for statistical analysis (e.g. outliers are removed).

Instructions for each template are included in the file itself.

## 4.3 Export the processed data/ analysis results

- The above script templates and some functions require you to specify an output folder where the output files (processed data or analysis results) will be exported to.
    - If the output folder does not exist, the scripts/functions will create the folder automatically.
    - If the output folder already exists, new output files will overwrite existing ones if they have identical names. Change to another folder unless you want to update the output files.
- Output file names are generated automatically.

> Some output files/variables can be read automatically for further processing. To avoid errors:
> - Do NOT rename variables inside a `.mat` file
> - Do NOT rename the following `.mat` files (unless you need to update the group names):
>    - `cdfParamsAndXyValues_\<group name\>.mat`
>    - `ieistats_all.mat`
>    - `gammastats_all.mat`

## 4.4 Optional: Build your own analysis pipeline

You can build your analysis pipeline by modifying any of the above templates. You can also create new pipeline from scratch using the functions in this Toolbox.

Inside each module's folder (e.g. [`/functions/kinetics`](/functions/kinetics/)), you will find functions that can be used directly to analyze one recording file (e.g. `nsfa.m`) or one group of recordings (e.g. `fitGroupDist.m`). For batch processing, you just need to run these functions iteratively on multiple recordings or groups (This is basically what the above templates do: e.g. `runNSFA.m` runs `nsfa.m` iteratively).

Alternatively, you can build your pipeline from scratch, using the functions in [`/functions/common/`](/functions/common/). The general steps are:
1. Import the raw data
2. Signal processing (e.g. detect peaks, compute frequency/IEI, etc.)
3. Transform data (e.g. merge datasets, bootstrap the data, etc.)
4. Signal analysis (e.g. decay fitting, NSFA, etc.)
5. Clean data (e.g. remove outliers, etc.)
6. Sort processed data (e.g. group data by conditions)
7. Statistical analysis
8. Export processed data/analysis results

# 5. About

## License

This Toolbox is licensed under the [GNU General Public License v3.0](https://github.com/manhowong/ephys-analysis-toolbox/blob/78d01eba0790664c0792e4cf3f39081448774af7/LICENSE).

## References

The core algorithm for non-stationary fluctuation analysis (NSFA) was inspired by:

**Hartveit, E., & Veruki, M. L. (2007).** Studying properties of neurotransmitter receptors by non-stationary noise analysis of spontaneous postsynaptic currents and agonist-evoked responses in outside-out patches. Nature protocols, 2(2), 434–448. https://doi.org/10.1038/nprot.2007.47
Fabius, J. (2022). violin (Version 1.0.0) [Computer software]. MATLAB Central File Exchange. Retrieved June 1, 2022. https://www.mathworks.com/matlabcentral/fileexchange/72424-violin

Code for CDF fitting was adapted from:

**Liu, M., Lewis, L. D., Shi, R., Brown, E. N., & Xu, W. (2014).** Differential requirement for NMDAR activity in SAP97β-mediated regulation of the number and strength of glutamatergic AMPAR-containing synapses. Journal of Neurophysiology, 111(3), 648–658. https://doi.org/10.1152/jn.00262.201


## Acknowledgement
We would like to thank the members of Schlueter Lab at the University of Pittsburgh, USA and University of Goettingen, Germany for their valuable input on the algorithm of NSFA.


