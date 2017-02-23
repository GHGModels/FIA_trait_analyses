# FIA_trait_analyses
Aggregating data for tree species in the FIA database.

This project does the following:
1. It takes species trait data, and tests for phylogenetic signal, and then performs phylogenetic independent contrasts to test if there is an effect of mycorrhizal status on a given trait, independent of phylogenetic signal.

2. It takes advantage of strong phylogenetic signal to phylogenetically infer traits for tree species in the FIA for which we do not have data. 

3. The project then queries the FIA based on search criteria to get FIA site data. This includes basal area by tree species, growth, recruitment and mortality data.

4. Using the basal area by species information we calculate plot level trait values. We then ask questions to determine if:
a. are traits are related to soil C storage in space?
b. can plot-level traits be predicted from environmental data (MAT/MAP/fire frequency/ndep) in space?
c. are plot level traits changing through time as a function of environmental conditions?