#This script aggregates green and senscent leaf data for FIA tree species. 
#data is from ORNL DAAC, here: https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=1106
rm(list=ls())
require(data.table)
foliar <- read.csv('raw_data/LEAF_CARBON_NUTRIENTS_1106/data/Leaf_Carbon_Nutrients_data.csv')
FIA_codes <- read.csv('raw_data/mycorrhizal_SPCD_data.csv')
foliar <- data.table(foliar)
FIA_codes <- data.table(FIA_codes)

#subset to only include observations that have a "Genus species" motif in the 'Species' column.
foliar <- foliar[grepl('^\\w+\\W\\w+$', foliar$Species),]

#break the 'Genus species' format of the 'Species' column into two separate columns.
foliar <- cbind(foliar, read.table(text = as.character(foliar$Species), sep = " "))
colnames(foliar)[which(names(foliar) == "V1")] <- "genus"
colnames(foliar)[which(names(foliar) == "V2")] <- "species"

#subset to only include species within the FIA, and have senescent N data.
FIA_codes$spp.match <- paste(FIA_codes$GENUS, FIA_codes$SPECIES, sep=' ')
foliar <- foliar[Species %in% FIA_codes$spp.match,]
foliar <- foliar[!is.na(foliar$N_senesced_leaf),]

#convert %N in senescent leaves to mg N per g leaf
foliar[,green_N_mg.g     := N_green_leaf * 10   ]
foliar[,senescent_N_mg.g := N_senesced_leaf * 10]

#aggregate data by unique species.
out               <- aggregate(senescent_N_mg.g ~ Species, FUN=mean, data = foliar)
out$green_N_mg.g  <- aggregate(green_N_mg.g     ~ Species, FUN=mean, data = foliar, na.action=na.pass)[,2]
out$Record_number <- aggregate(Record_number    ~ Species, FUN=median, data = foliar)[,2]
#break out genus species again
out <- cbind(out, read.table(text = as.character(out$Species), sep = " "))
colnames(out)[which(names(out) == "V1")] <- "genus"
colnames(out)[which(names(out) == "V2")] <- "species"
out$genus_species <- paste(out$genus, out$species, sep='_')

#pop in mycorrhizal status and FIA species codes
#subset FIA_codes that are in the output data set
sub <- FIA_codes[spp.match %in% out$Species,]
sub <- sub[!duplicated(sub$spp.match),]
out <- merge(out, sub[,.(spp.match,MYCO_ASSO,SPCD)],by.x = 'Species', by.y = 'spp.match')

#get rid of space separated Species column
out <- out[,!names(out) %in% c('Species')]

#make rownames genus_species, only include two N traits
rownames(out) <- out$genus_species

#get AM and ECM data sets
out.AM  <- out[out$MYCO_ASSO == 'AM' ,]
out.ECM <- out[out$MYCO_ASSO == 'ECM',]


#save output for downstream analysis
saveRDS(out    , 'analysis_data/species_foliar_N.rds')
saveRDS(out.AM , 'analysis_data/species_foliar_N_AM.rds')
saveRDS(out.ECM, 'analysis_data/species_foliar_N_ECM.rds')
write.csv(out    ,'analysis_data/species_foliar_N.csv')
write.csv(out.AM ,'analysis_data/species_foliar_N_AM.csv')
write.csv(out.ECM,'analysis_data/species_foliar_N_ECM.csv')
