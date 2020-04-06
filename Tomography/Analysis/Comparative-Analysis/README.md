# Tomography Analysis
Code for processing and comparative analysis of tomogram segmentation data

## Comparative Analysis

Analyses pore and particle surface data and plots comparative figures

Instructions: (1) set how scans are compared & specify data labels in the "overlay" functions (2) enter all scans to be compared into "tomo_figs.m" and run (3) find the maximum value of "plotmax" from the output data struct, and enter as "maxplotmax" in line 80 of "pore_totvol_dist_plot.m" (4) run "tomo_figs.m" again

Dependencies: output of pore_dist_looper.m ("pore_data_um_scan.mat" for each scan to be compared)
