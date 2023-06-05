# Load required libraries
library(ncdf4)         # For working with NetCDF files
library(chron)         # For working with dates and times
library(lattice)       # For creating lattice plots
library(ggplot2)       # For creating ggplot2 plots
library(gridExtra)     # For arranging multiple plots
library(plyr)          # For data manipulation
library(RColorBrewer)  # For color palettes
library(reshape2)      # For data reshaping

# Set path and filename
ncpath <- "/run/media/guigeek/data_works/Beetle_outbreak/FG2_paper/"  # Set the path to NetCDF files
nclat <- c("61.8","55.5","50.9","49.0","48.4","48.7","46.5","41.8")   # Latitude values
ncMAT <- c(4.25,8.18,8.7,8.2,11.2,10.2,4.5,7.2)                      # Mean annual temperature values
# ... and other variable definitions

# Define label mappings for plotting
lab01 = c(
  "4.25" = "HYY",
  "8.18" = "SOR",
  "8.7" = "THA",
  "8.2" = "WET",
  "11.2" = "FON",
  "10.2" = "HES",
  "4.5" = "REN",
  "7.2" = "COL"
)

lab02 = c(
  "HYY(4.3)",
  "SOR(8.2)",
  "THA(8.7)",
  "WET(8.2)",
  "FON(11.2)",
  "HES(10.2)",
  "REN(4.5)",
  "COL(7.2)"
)

# Define color palettes
cbp1 <- c("#999999","#56B4E9","#E69F00", "#F0E442",
          "#999999","#009E73", "#0072B2", "#D55E00", "#CC79A7")
cbp2 <- c("#0072B2","#009E73","#D55E00","#CC79A7","#0072B2")
cbp3 <- c("#009E73","#D55E00","#CC79A7","#009E73")

l=0
simu <- data.frame()

# Loop over variables and files to read and process NetCDF data
for (k in ncname) {
  l=l+1
  for (p in exp) {
    for (i in int) {
      for (n in file) {
        if (!file.exists(paste(ncpath,k,"FG2",p,i,"_",n,".nc", sep=""))) next

        # Read NetCDF file
        ncfname <- paste(ncpath,k,"FG2",p,i,"_",n,".nc", sep="")
        ncin <- nc_open(ncfname)
        dname = names(ncin$var)[-(1:3)]

        # Loop over variables in the file
        q = 0
        for (j in dname) {
          q = q+1
          if (j=="WOOD_VOL_PIX_CUT") {
            # Process specific variable
            m = as.matrix(ncvar_get(ncin,j))
            ext_value = as.vector(apply(m,2,sum))
            #
        # Do something with the processed variable (e.g., store in a data frame)
      } else {
        if (base::grepl("O",p) & n=="SRF") {
          if (j == "transpir") m = as.matrix(ncvar_get(ncin,j)[4,])
          else m = as.matrix(ncvar_get(ncin,j))
          fac <- ((seq_len(nrow(m))-1) %/% 12)+1
          ext_value = as.vector(apply(m, 2, function(v) tapply(m, fac, func[q][[1]])))
        } else ext_value = ncvar_get(ncin,j)
        
        if (length(dim(ext_value)) > 1) {
          if (length(dim(ext_value)) > 2) ext_value = ext_value[4,3,]
          else ext_value = ext_value[4,]
        }
      }
      
      # Create a data frame with the processed values
      temp <- data.frame(time = years,
                         site = rep(k,length(years)),
                         exp = rep(p,length(years)),
                         wind = rep(i,length(years)),
                         rad = rep(ncRAD[l],length(years)),
                         mgr = rep(ncMGR[l],length(years)),
                         map = rep(ncMAP[l],length(years)),
                         mat = rep(ncmAT[l],length(years)),
                         elev = rep(ncelev[l],length(years)),
                         lat = rep(nclat[l],length(years)),
                         var = rep(j,length(years)),
                         value = ext_value)
                         
      # Add the temporary data frame to the main data frame
      simu <- rbind(simu,temp)
    }
    
    # Close the NetCDF file
    nc_close(ncin)
  }
}

# Perform further data processing and analysis
# Subset the data frame to select specific variables
NPP = subset(simu, var == "NPP")
HET = subset(simu, var == "HET_RESP")
NBP = NPP
NBP$value = NPP$value - HET$value
NBP$var = "NBP"
simu = rbind(simu, NBP)

# Update variable names in the data frame
var_names = levels(as.factor(simu$var))
names(simu) = c(
  "time", "Fluxnet_Site", "exp", "wind", "rad", "mgr",
  "Mean_annual_precipitation", "Min_annual_temperature", "elev",
  "Latitude", "var", "value"
)

# Create plots and save them as PNG or SVG files
# Plotting figure_3
svg("figure_3.png", width = 18, height = 18)
# Create a bar plot using ggplot2
ggplot(resM, aes(x = outbreak_int / 2, y = value)) +
  geom_bar(aes(fill = variable, width = outbreak_int), stat = "identity") +
  coord_polar("y", start = 0) +
  facet_grid(MAT + Fluxnet_Site ~ wind, switch = "y") +
  scale_fill_manual(values = cbp1) +
  geom_hline(yintercept = c(0, 11, 6), linetype = 3) +
  ylab("") + xlab("") +
  scale_y_continuous(breaks = c(0, 11, 6), labels = c(0, 1, 6)) +
  theme_classic() +
  theme(strip.text.y.left = element_text(angle = 0))
dev.off()

# Plotting figure_4
png("figure_4.png", width = 900, height = 1100)
# Create line plots using ggplot2
ggplot(subset(simu, var == "NPP" & exp == "OWB"),
       aes(y = value, x = time, color = as.factor(wind))) +
  geom_line(size = 1.5) +
  ylim(0, 2.1) + xlim(0, 15) +
  facet_wrap(vars(Fluxnet_Site, Min_annual_temperature),
             nrow = 4,
             labeller = label_bquote(.(Fluxnet_Site) : .(Min_annual_temperature) ~ (degree * C))) +
  theme(strip.text.y.left = element_text(angle = 0)) +
  ylab("Net Primary Production (tC/ha)") +
  xlab("Time since the start of the simulation (year)") +
  theme_classic(base_size = 17) +
  theme(legend.position = 'top', legend.spacing.x = unit(1.0, 'cm')) +
  theme(strip.background = element_blank(), strip.placement = "outside") +
  guides(color = guide_legend(title = "Wind speed max(m/s)"))
dev.off()

# Perform additional data processing and analysis
# Subset the data frame to select specific variables and time points
df = subset(simu, var == "NPP")
DF.t <- ddply(df, .(Fluxnet_Site, exp, wind), transform, cy = cumsum(value))
ddd = subset(DF.t, var == "NPP" & exp == "OWB" & time == 15)

# Write the subsetted data frame to a CSV file
write.table(ddd, "ddd.csv", row.names = FALSE)

# Create plots and save them as PNG or SVG files
# Plotting figure_5
svg("figure_5.png", width = 9, height = 9)
# Create a grouped column plot using ggplot2
ggplot(ddd, aes(x = cy, y = Fluxnet_Site, fill = as.factor(wind))) +
  geom_col(position = "dodge") +
  theme_classic(base_size = 17) +
  theme(legend.position = 'top', legend.spacing.x = unit(1.0, 'cm')) +
  theme(strip.background = element_blank(), strip.placement = "outside") +
  guides(fill = guide_legend(title = "Wind speed max(m/s)")) +
  xlab("Cummulative Net primary Production over 15 years(tC/ha/15 years)") +
  ylab("")
dev.off()

ddd = subset(DF.t, var == "NBP" & (exp == "OWB" | exp == "OC") & (time == 20 | time == 50 | time == 100))
ddd20OC = subset(ddd, time == 20 & exp == "OC")
ddd20OWB = subset(ddd, time == 20 & exp == "OWB")
				      
# Plotting figure_6				      
pdf("figure_6.png", width = 8, height = 4.5)
# Create a boxplot using ggplot2
ggplot(ddd, aes(x = as.factor(time), y = cy * 365 / 100, fill = exp)) +
  geom_boxplot() +
  scale_fill_manual(values = cbp3) +
  ylab("Accumulated Net Biome Production (tC/ha)") +
  xlab("Years after the windthrow event") +
  theme(strip.background = element_blank(), strip.placement = "outside") +
  theme_classic()
dev.off()

