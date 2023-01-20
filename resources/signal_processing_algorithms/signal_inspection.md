# Signal inspection

Man Ho Wong  
Xu Lab, Department of Neuroscience, University of Pittsburgh.

Signals are inspected before analysis to exclude noisy/ unstable traces and traces with overlapping events from the analysis.

This page documents the algorithm of signal inspection, which is implemented through the function [`dropBadTraces.m`](../../functions/common/signal_processing/dropBadTraces.m).

# Traces to be excluded

1. The amplitude of a trace's tail falls outside a user-defined range (relative to the average trace). This indicates unstable recording.
2. The baseline falls outside a user-defined range (relative to the trace tail). This indicates unstable recording.
3. The event in the trace does not pass the detection thresholds (i.e. no event detected) or the trace has more than one event (i.e. overlapping events).
4. The peak occurs 1 ms or later after the average peak.

Examples of traces passing the above criteria ↓

<img src="../img/passed_trace.svg" height="400">

<img src="../img/passed_trace_small.svg" height="400">

Example showing traces removed from analysis and the remaining traces ↓

<img src="../img/dropped_traces.png" height="400">

Some examples of the removed traces are shown below.

A trace with multiple peaks ↓

<img src="../img/dropped_by_manypeaks.svg" height="400">

An unstable trace ↓

<img src="../img/dropped_by_stability2.svg" height="400">

A trace without detectable events ↓

<img src="../img/dropped_by_ampl.svg" height="400">

# Steps

## 1. Find unstable traces 

Unstable traces are defined as:
- traces with tails (ending region of the trace) outside of a user-defined range (e.g. one standard deviation of tail amplitude)
- traces with baseline outside the same range as for tails (This indicates a significant change in baseline during the time course of the trace).

## 2. Find traces with no event or with multiple peaks (i.e. overlapping events)

See [signal_detection.[md](/signal_detection.md) for the detection of peaks.

## 3. Drop traces found in steps 1 and 2

## 4. Compute the average trace

## 5. Find the peak location of the average trace (average peak)

## 6. Find traces with peaks occurring 1 ms or later after the peak of the average trace

## 7. Drop traces found in step 6



