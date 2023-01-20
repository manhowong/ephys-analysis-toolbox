# Membrane properties analysis

Man Ho Wong  
Xu Lab, Department of Neuroscience, University of Pittsburgh.

This page documents the algorithm of membrane properties analysis, which is implemented through the function [`membraneProps.m`](../../functions/membrane_props/membraneProps.m).

# Steps

## 1. Zero every trace

Zero every trace of capacitance transient by the average amplitude of its own baseline (defined by the user, e.g. 0 to 4 ms of the trace).

## 2. Get the average trace

## 3. Determine transient peak direction by test pulse direction

## 4. Find the peak location

The location of the first transient peak is defined as the first sampling point with either minimum or maximum value depending on peak direction.

## 5. Locate the decay window

The decay window is defined as the decay from the peak location to the user-defined end point (this depends on the length of test pulse).

## 6. Zero the trace in the decay window to the stable current

The stable current ($I_{stable}$) is the difference between the baseline and the last 10 sampling points of the decay window.

## 7. Fit decay to a first-order exponential function

The trace within the decay window is fitted to a first-order exponential function using the non-linear least squares method. The function is shown below:

$I = I_0 \cdot e^{-t/tau}$ 

where $I_0$ is the initial current (i.e. peak).

## 8. Compute passive membrane properties

The decay time constant (tau) is obtained directly from the fitting result. Other passive membrane properties are defined as follows:


$R_{input} = V_{test\ pulse}/I_{stable}$

$R_{series} = V_{test\ pulse}/I_{peak}$

$C_{membrane} = tau/R_{series}$

where

$R_{input}$ = input resistance

$R_{series}$ = series resistance

$C_{membrane}$ = membrane capacitance

$V_{test\ pulse}$ = test pulse size

$I_{stable}$ = stable current (see step 6)

$I_{peak}$ = peak current