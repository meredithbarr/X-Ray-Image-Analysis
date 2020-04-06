# Tomography Analysis
Code for processing and comparative analysis of tomogram segmentation data

## Data Processing

Determines properties and locations of individual pores and particle surfaces from tomogram segmentations.

Instructions: enter scans and slice ranges to be analysed into "pore_dist_looper.m" and run

Dependencies: output of Tomo_seg_interactive_laptop.m ("input_params_scan.mat", pore mask slices (.tiff), and solid mask slices (.tiff)
for each included scan)

Note: this code requires approx. 260 GB of RAM to analyse the dataset it was written for. It was designed to run remotely on an HPC cluster.
