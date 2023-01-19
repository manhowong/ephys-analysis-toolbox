# Signal detection

Man Ho Wong  
Xu Lab, Department of Neuroscience, University of Pittsburgh.

This page documents the algorithm of signal peak detection, which is implemented through the function [`findPeaks.m`](../../functions/common/signal_processing/findPeaks.m).

# Steps

## 1. Noise reduction

Signal noise is reduced by smoothing the raw trace with a digital low-pass filter ([Savitzky-Golay filter](https://en.wikipedia.org/wiki/Savitzky%E2%80%93Golay_filter)). The default length of window (number of points) used in smoothing is defined as

$ window\:length = sampling\:frequency \times 3 \div 1000 $

> Noise can also be filtered by other types of filters. However, for the purpose of peak detection, they are usually less efficient than signal smoothing.

## 2. Compute gradient of every sampling point of the smoothed trace

Finite differences are used for the approximation of derivatives. For interior sampling points, central differences are computed. For the first and last sampling points, single-sided differences are computed. For more info, see [this](https://www.mathworks.com/help/matlab/ref/gradient.html#bvifdfu-5) and [this](https://en.wikipedia.org/wiki/Finite_difference). 

Numerical gradients are computed as described above with a point spacing of one. Then, the gradients are corrected to the actual time interval between two points.

This step generate an array of gradients for each trace.

## 3. Smooth gradient array

To remove zero-crossings due to noise, the gradient array of every trace is smoothed by the Savitzky-Golay filter with the same window length as in step 1.

> Instead of filtering the raw signals with a more stringent setting (e.g. low cutoff frequency) to remove as much as noise as possible in one step, this algorithm filters the raw signals with a less stringent filter in two steps: before and after gradient computation. The advantage of this two-step strategy is that the signal-to-noise ratio of the raw traces is enhanced after filtering while keeping the signal shape distortion minimal for accurate gradient computation.

## 4. Find zero-crossings

A zero-crossing is a point where the direction (i.e. sign) of gradients switches (e.g. for downward peaks, sign switches from negative to positive).

## 5. Detect signal peaks

If the rise gradient and the decay gradient surrounding a zero-crossing pass the gradient thresholds, and the amplitude passes the amplitude threshold, the zero-crossing will be detected as a signal peak.