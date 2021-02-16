## This code (hopefully) will read spatial and brood location data from the Utkiagvik habitat use
    # and analyze habitat use by as of yet undetermined variables 

#install packages
library(gdalUtils) #access geo tiff metadata
library(raster)
library(rgdal) 
library(sp)
library(ggplot2)

#plot maps
setwd("D:\\habitat_use_eiders\\data\\raw_data\\1_11a_detailed_wetlands")
wetland.map.NE <- raster("1_11a_detailed_wetlands_NE.IMG")
wetland.map.SE <- raster("1_11a_detailed_wetlands_SE.IMG")
wetland.map.NW <- raster("1_11a_detailed_wetlands_NW.IMG")
wetland.map.SW <- raster("1_11a_detailed_wetlands_SW.IMG")


NE.plot <- ggplot(wetland.map.NE, main= "Northeast Wetland")


###adjust brood locations for 2005, 2006, 2008 (IS_OFFSET = 0)
setwd("D:/habitat_use_eiders/data/raw_data")
all.data <- read.csv("stei_spei_brood_locs_20210210.csv")


###PLAY TIME### 
tester2 <- data.frame(all.data$UTM.Easting..LRB.added.[181:185])
tester <- data.frame(all.data$UTM.Northing..LRB.added.[181:185])
tested <- merge(tester2, tester) ##make sure that x, y are in the right order!!! 
spacial.test <- SpatialPoints(tested, proj4string = CRS("+proj=utm +zone=04 +datum=WGS84"))
spatial.transform <- spTransform(spacial.test, CRS("+proj=longlat +datum=WGS84"))
space <- data.frame(spatial.transform)










