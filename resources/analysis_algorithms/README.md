# EPSC kinetics analysis

Man Ho Wong  
Xu Lab, Department of Neuroscience  
University of Pittsburgh

---

The decay of miniature EPSC events (mEPSCs) from single-neuron recordings contains useful information about the ion channel properties. This module consists of two parts: (1) decay analysis; and (2) non-stationary fluctuation analysis (NSFA).

1. Decay analysis  
The decay time constant of each mEPSC event can be computed by fitting the decay phase to a first-order exponential decay model by non-linear least squares approach.

2. non-stationary fluctuation analysis (NSFA)  
The fluctuation of current amplitudes at different time points during an mEPSC event is stochastic in nature and is determined by ion channel properties. Ion channel properties such as single-channel conductance and ion channel number, which are difficult to observe empirically, can be computed statistically by NSFA. Briefly, the variance-mean relationship of EPSC amplitude is fitted with a parabola function based on a binomial model for quantal neurotransmitter release.

The above analyses are very sensitive to noise because of the low signal-to-noise ratio of miniature signals. To cope with this, we developed an algorithm to detect and remove noisy signals automatically (see [`nsfa.md`](nsfa.md)). 