# Bark Beetle Outbreak Simulation

This R script runs simulations of a bark beetle outbreak module, collects results, and then creates a plot to visualize these results. Here is an overview of the script:

## 1. Library Import and Variable Initialization

The script begins by importing several libraries necessary for the operations carried out:

- `ncdf4`: For working with NetCDF files, a format commonly used to store array-oriented scientific data.
- `chron`: For handling chronological objects like dates and times.
- `lattice` and `ggplot2`: For data visualization.
- `gridExtra`: For arranging multiple grid-based plots on a page.
- `plyr`: For data manipulation.
- `RColorBrewer`: For color palettes.
- `reshape2`: For restructuring and aggregating data.

Several variables are then initialized, most of which seem to represent various environmental and simulation parameters (e.g., latitude, mean annual temperature, mean growth rate, mean annual precipitation, radiation, and elevation for different locations, etc.)

# Libraries
library(ncdf4)  
library(chron)  
library(lattice)  
library(ggplot2)  
library(gridExtra)  
library(plyr)  
library(RColorBrewer)  
library(reshape2)  

## 2. Simulation Loop
This part of the script is where the main loop of the simulation happens. 
The loop goes through each location (ncname), each experiment (exp), each intervention (int), and each file (file). 
For each combination, it checks if the corresponding NetCDF file exists. 
If it does, it opens the file and retrieves the data associated with the variable names present in the file, excluding the first three variables.

For the variable named WOOD_VOL_PIX_CUT, it applies a function across the second dimension (columns) 
of the matrix and stores the result in the ext_value variable. Then, it calculates cumsum(seqBPI)[period] and statel for different conditions.

## 3. Data Processing and Visualization
After the simulations are complete, the script reshapes the results data using the melt function from the reshape2 library, 
keeping certain variables as identifiers. It then removes rows where value equals 0.

Finally, the script creates a bar plot of the processed results using ggplot2. 
The bars are filled based on the variable field, the width is set by outbreak_int, and the plot is faceted by MAT+Fluxnet_Site~wind. 
The plot is saved as a PNG file named "figure_3.png".

In summary, this code is designed to run simulations for a bark beetle outbreak model across different sites, 
scenarios, interventions, and parameters, collect the results, process the data, and create a plot to visualize the results.
