# Multi-Language MRS Processing Library

 This project aims to create a standardized library of basic and advanced data processing classes in the most widely used programming languages. The foundational building blocks of this library will be the basic MRS processing steps (zero-filling, line-broadening, concatenating and splitting transients, etc.). As the library grows, more complex methods will hopefully be incorporated.

## Getting Started

### Download some example NIfTI-MRS data files

I have included one single-voxel test file (Siemens short-TE PRESS; in this repository.

There are several additional example data in the folder 'examples' under <https://github.com/wtclarke/mrs_nifti_standard/tree/master/example_data>.

### Find some inspiration

MATLAB: <https://github.com/schorschinho/nifti-mrs-matlab> (you can use the svs_preprocessed.nii.gz file in this repository!)
Python: <https://github.com/wtclarke/nifti_mrs_tools>
R: <https://martin3141.github.io/spant/> & <https://github.com/jonclayden/RNifti/>

### ... just code :-)

## Background

## NIfTI-MRS

[NIfTI-MRS Data Standard Repository](https://github.com/wtclarke/mrs_nifti_standard)
[NIfTI-MRS Paper](https://onlinelibrary.wiley.com/doi/full/10.1002/mrm.29418)

## Functions that might be useful

Will Clarke already has a nice array of Python tools acting on NIfTI-MRS objects: <https://github.com/wtclarke/nifti_mrs_tools/tree/master/src/mrs_tools>
FID-A comes with a ton of functions that can serve as reference: <https://github.com/CIC-methods/FID-A>
Osprey is built on FID-A, but has a lot of additional customized functions: <https://github.com/schorschinho/osprey>
Martin Wilson's spant in R has NIfTI-MRS read/write functions: <https://martin3141.github.io/spant/>

### Basic I/O

These methods/functions take a NIfTI-MRS file (*.nii) and get them into the workspace of your particular language so you can operate on the data. (And after you're done, you also want to save them back into a*.nii file!).

#### Load NIfTI file into an object/array/struct

How to load NIfTI-MRS data in MATLAB: <https://github.com/schorschinho/nifti-mrs-matlab> (you can use the svs_preprocessed.nii.gz file in this repository!)
Will Clarke's Python NIfTI-MRS tools build on a customized loader

#### Save object/array/struct into a NIfTI file

#### Just print some basic info (dimensions, header values, etc.) for quick inspection, but don't load

### Operations on the FID

These methods/functions change the data themselves in a certain way.

#### Apply a frequency shift (in Hz)

#### Apply a phase shift

- zero-th order (in degrees or radians)
- first order (in degrees per ppm or radians per ppm) with the chosen pivot point

#### Apply linebroadening (in Hz)

- Exponential (Lorentzian)
- Gaussian

#### Zero-filling

#### Make the complex conjugate

#### Truncate n points at the start/end of the FID

#### Cropping data points from a FID or spectrum

- in the time domain (based on indices or physical time)
- in the frequency domain (based on indices or ppm)

#### Scale up/down by a scalar

### Operations on datasets

#### Merge multiple datasets along a certain dimension

- Warnings if the other dimensions don't match

#### Split a dataset into multiple datasets along a certain dimension

#### Take spectra with certain indices or dimensions and save to new dataset

#### Append a single FID to a certain dimensions

### Measurement

#### Measure linewidth (FWHM)

#### Measure SNR

### Visualization

#### Plot a single dataset

- time domain
- frequency domain
- arguments: plot range
- if multiple dimensions, which one?

#### Fully interactive visualization GUI

- Time- or frequency-domain display
- Select dimensions to display
- Single transients or means across a certain dimension
- Flexible x and y scaling
- Display header and extended header info
- Overlay with structural
