## This code (hopefully) will read spatial and brood location data from the Utkiagvik habitat use
    # and analyze habitat use by as of yet undetermined variables 

#install packages
library(gdalUtils) #access geo tiff metadata
library(raster)
library(dplyr)
library(stringr)
library(rgdal) 
library(sp)
library(ggplot2)
library(geosphere)


###adjust brood locations for 2005, 2006, 2008 (IS_OFFSET = 0 need adjustment)
all.data <- read.csv("data/raw_data (old)/stei_spei_brood_locs_20210223.csv")
#transform all UTM data into long lat data #long lat column (in that order)

UTM.spatial <- SpatialPoints((subset(all.data, all.data$CAT_YEAR == 2012 & (all.data$ID_BROOD == "12-SAM019" 
                                                                            | all.data$ID_BROOD == "12-MTW059"), 
                                     select = c("VAL_UTM_EASTING..LRB.added.", "VAL_UTM_NORTHING..LRB.added."))), proj4string = CRS("+proj=utm +zone=04 +datum=WGS84"))

UTM.transform <- data.frame(spTransform(UTM.spatial ,CRS("+proj=longlat +datum=WGS84") ))

write.csv(UTM.transform, "data/raw_data (old)/UTM_transformed.csv")



##transformed lat longs were manually replaced in stei_spei_brood_locs_livingdoc.xlsx excel sheet

#transform directions into degrees (new column) 

data <- read.csv("data/raw_data (old)/stei_spei_brood_locs_20210224.csv")
levels(data$VAL_OFFSET_BERING)
# ""    "E"   "ENE" "N"   "na"  "NE"  "NNW" "NW"  "S"   "SE"  "SSE" "SSW" "SW"  "W"   "WNW"

#convert from cardinal direction to degrees
new.bering <- data %>% mutate(VAL_OFFSET_BERING_DEGREES = case_when(data$VAL_OFFSET_BERING == "N" ~ 0,
                                                                    data$VAL_OFFSET_BERING == "NE" ~ 45,
                                                                    data$VAL_OFFSET_BERING == "ENE" ~ 67.5,
                                                                    data$VAL_OFFSET_BERING == "E" ~ 90, 
                                                                    data$VAL_OFFSET_BERING == "SE" ~ 135,
                                                                    data$VAL_OFFSET_BERING == "SSE" ~ 157.5,
                                                                    data$VAL_OFFSET_BERING == "S" ~ 180,
                                                                    data$VAL_OFFSET_BERING == "SW" ~ 225,
                                                                    data$VAL_OFFSET_BERING == "SSW" ~ 247.5,
                                                                    data$VAL_OFFSET_BERING == "W" ~ 270,
                                                                    data$VAL_OFFSET_BERING == "WNW" ~ 292.5,
                                                                    data$VAL_OFFSET_BERING == "NW" ~ 315,
                                                                    data$VAL_OFFSET_BERING == "NNW" ~ 337.5))
#remove units ('m') from new column 
clean.data <- new.bering %>% mutate(VAL_OFFSET_DIST_ADJ = str_remove(data$VAL_OFFSET_DIST, "[m]"))
#convert from feet to meters
clean.data$VAL_OFFSET_DIST_ADJ <- replace(clean.data$VAL_OFFSET_DIST_ADJ, clean.data$VAL_OFFSET_DIST_ADJ == "150 FEET", 150/3.281)
clean.data$VAL_OFFSET_DIST_ADJ <- replace(clean.data$VAL_OFFSET_DIST_ADJ, clean.data$VAL_OFFSET_DIST_ADJ == "100 FEET", 100/3.281)
clean.data$VAL_OFFSET_DIST_ADJ <- replace(clean.data$VAL_OFFSET_DIST_ADJ, clean.data$VAL_OFFSET_DIST_ADJ == "70 FEET", 70/3.281)
clean.data$VAL_OFFSET_DIST_ADJ <- replace(clean.data$VAL_OFFSET_DIST_ADJ, clean.data$VAL_OFFSET_DIST_ADJ == "30 FEET", 30/3.281)
#THIS WORKS ^

startpoints <- clean.data[c(9,8)]

endpoints <- destPoint(startpoints, clean.data$VAL_OFFSET_BERING_DEGREES, clean.data$VAL_OFFSET_DIST_ADJ)
#THIS WORKS ^ 

clean.data <- cbind(clean.data, endpoints)

#run destpoint
#clean.data <- clean.data %>% rowwise() %>% 
#mutate(End_lon = if(IS_OFFSET == 0)
 # {destPoint(c(VAL_LON, VAL_LAT), c(VAL_OFFSET_BERING_DEGREES), c(VAL_OFFSET_DIST_ADJ))} 
#  else{NA}) %>%
 # ungroup()
  
# clean.data <- clean.data %>% rowwise() %>% 
#   mutate(End_lon = ifelse(IS_OFFSET==0,
#          destPoint(c(clean.data$VAL_LON, clean.data$VAL_LAT), c(clean.data$VAL_OFFSET_BERING_DEGREES), c(clean.data$VAL_OFFSET_DIST_ADJ)),NA))  # %>%
#   ungroup
# 
#   #run destpoint
#   clean.data <- clean.data %>% filter(IS_OFFSET == 0) %>% rowwise() %>%
#   mutate(End_lon = destPoint(c(VAL_LON, VAL_LAT), c(VAL_OFFSET_BERING_DEGREES), c(VAL_OFFSET_DIST_ADJ))) %>%
#   ungroup()


   # mutate(offset = destPoint(p = c(clean.data$VAL_LON, clean.data$VAL_LAT), 
 #                          b = c(clean.data$VAL_OFFSET_BERING_DEGREES), d = c(clean.data$VAL_OFFSET_DIST_ADJ))
  #)

#plot maps with new offset lat long

wetland.map.NE <- raster("/data/habitat_gis/1_11a_detailed_wetlands/1_11a_detailed_wetlands_NE.IMG")
wetland.map.SE <- raster("1_11a_detailed_wetlands_SE.IMG")
wetland.map.NW <- raster("1_11a_detailed_wetlands_NW.IMG")
wetland.map.SW <- raster("1_11a_detailed_wetlands_SW.IMG")


NE.plot <- ggplot(wetland.map.NE, main= "Northeast Wetland")












