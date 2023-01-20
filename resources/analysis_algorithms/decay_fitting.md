# Event decay fitting

Man Ho Wong  
Xu Lab, Department of Neuroscience, University of Pittsburgh.

This page documents the algorithm of decay fitting, which is implemented through the function [`fitDecay.m`](../../functions/kinetics/fitDecay.m).

# Steps

## 1. Zero every trace

Zero every trace by the average amplitude of its own baseline (defined by the user, e.g. 0 to 4 ms of the trace).

## 2. Drop unstable traces and traces with overlapping events

See [signal_inspection.md](../signal_processing_algorithms/signal_inspection.md).

## 3. Find the peak location

The peak of a downward signal is defined as the first sampling point with the minimum value.

## 4. Locate the decay window

The decay window is defined by the user, e.g. from 100% to 0% of the peak.

To locate the window, the theoretical amplitude at 95% of the peak and at 10% of the peak are calculated from the average peak amplitude as the amplitude at the decay start point and at the decay end point respectively. Sampling points matching the exact theoretical amplitudes likely do not exist in the trace, but the points nearest to the theoretical decay start point and end point can be used. To minimize the effect of noise on the decay window location, three sampling points are used as the search window for the decay start point and end point.

## 5. Fit decay to a first-order exponential function

The trace within the decay window is fitted to a first-order exponential function using the non-linear least squares method. The function is shown as below:

$I = I_0 \cdot e^{-t/tau}$ 

where $I_0$ is the initial current (i.e. peak).

## 6. Remove badly fitted events from the results

Events will smaller amplitude have bad fitting in general. Therefore, events with a peak amplitude less than the threshold (5 pA in the source code) are removed.

Since the decay time constant (tau) must be greater than 0 ms, events will also be removed if they have negative tau.


