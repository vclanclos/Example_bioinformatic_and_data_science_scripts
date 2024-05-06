## Note: this code was published for Lanclos et al. 2023 as part of the thrash-lab organization at https://github.com/thrash-lab. 
## The code redisplayed here is simply to highlight my (Lanclos) profiency in R dataframes and ecological data mapping.

rm(list=ls()) 
require(RColorBrewer)
library(ggplot2)
library(tidyr)
library(reshape2)
require(plyr)
require(dplyr)
library(ggpubr)

#RPKM data and metadata merge
all_rpkm<- read.csv("RPKM.csv", header=T)
metadata<- read.csv("Recruitment_metadata.csv", header=T)
metadata <- metadata[c("SRA_accession", "Salinity", "Region")]
mdata <- melt(all_rpkm, id=c("ACC"))
mdata <-dplyr::rename(mdata, Genome=ACC, SRA_accession=variable, RPKM=value)
merged <-merge(mdata,metadata,by="SRA_accession")

#Add in subclades
subclades<- read.csv("Accs_checkm_gen_stats.csv", header=T)
merged2 <-merge(merged,subclades,by="Genome")

#Remove sites without salinity values and subclade V since it is the outgroup
no_na<-merged2 %>% drop_na("Salinity")
no_na <- no_na[!(no_na$Subclade == "V"),]
length(unique(no_na$SRA_accession))
accs<-unique(no_na$SRA_accession)
accs<-as.data.frame(accs)

#Uncheck to see which regions made it into the analysis after dropping salinity free samples
regions <- split(no_na, as.factor(no_na$Region))

#Adds in the salinity categories using the Venice system
no_na2<- no_na %>% 
  mutate(Sal_cat = case_when(no_na$Salinity <= 0.5 ~ "Fresh <0.5", 
                             no_na$Salinity >=0.5 & no_na$Salinity <=5 ~ "Oligohaline 0.5-4.9",
                             no_na$Salinity >=5 & no_na$Salinity <=18 ~ "Mesohaline 5.0-17.9",
                             no_na$Salinity >=18 & no_na$Salinity <=30 ~ "Polyhaline 18.0-29.9",
                             no_na$Salinity >=30 & no_na$Salinity <40 ~"Euhaline 30.0-39.9",
                             no_na$Salinity >=40 ~"Hyperhaline 40.0+"))

#Sums the data by subclade and salinity category in any given sample.
test_sum4<- no_na2 %>%
  group_by(SRA_accession, Subclade, Sal_cat) %>%
  summarise(Sum_RPKM=sum(RPKM))

#Orders the salinity categories in increasing salinities
test_sum4$Sal_cat <- factor(test_sum4$Sal_cat , levels=c("Fresh <0.5","Oligohaline 0.5-4.9",
                                                         "Mesohaline 5.0-17.9", "Polyhaline 18.0-29.9", 
                                                         "Euhaline 30.0-39.9","Hyperhaline 40.0+"))


#Plots boxplot for all subclades without a log scale
ggplot(test_sum4,aes(x = Subclade, y = Sum_RPKM,fill=Sal_cat),dodge=Sal_cat ) + 
  geom_boxplot(varwidth = FALSE) + 
  labs(title="All subclades with updated RPKM calcs 062322")+
  theme_classic()

#Various ways to subset the data for mining
Summed_IIIab <- subset(test_sum4, Subclade == "IIIa.1" | Subclade == "IIIa.2" | Subclade == "IIIa.3" |Subclade == "IIIb")
Summed_IIIa <- subset(test_sum4, Subclade == "IIIa.1" | Subclade == "IIIa.2" | Subclade == "IIIa.3")
Raw_IIIab <- subset(no_na2, Subclade == "IIIa.1" | Subclade == "IIIa.2" | Subclade == "IIIa.3")
Raw_IIIa1 <- subset(no_na2, Subclade == "IIIa.1")

#Plots the log transformed zoom in of IIIa
ggplot(Summed_IIIa,aes(x = Subclade, y = Sum_RPKM,fill=Sal_cat),dodge=Sal_cat) + 
  geom_boxplot(varwidth = FALSE) + 
  labs(title="IIIa summed per subclade in sample plotted by salinity category")+
  scale_y_log10()+
  theme_classic()

#Tile plots for recruitment data to highlight IIIa
III <- subset(no_na, Subclade == "IIIa.1" | Subclade == "IIIa.2" | Subclade == "IIIa.3" |Subclade == "IIIb")
III$Genome<-factor(III$Genome,
                   levels = c(
                     "MED1116",
                     "AG_895_L23",
                     "AG_470_E16",
                     "LSUCC0723",
                     "TMED146",
                     "HIMB114",
                     "CP_2",
                     "LSUCC0664",
                     "AG_359_E06",
                     "AG_894_A09",
                     "MED817",
                     "CP_55",
                     "SFB_9D_13Oct25_20_ms_bin_25_orig",
                     "SFB_3D_13Oct25_20_ms_bin_3_orig",
                     "CP_31",
                     "QL1",
                     "CP_1",
                     "IMCC9063",
                     "CP_15",
                     "LSUCC0261",
                     "SCGCAAA027_C06",
                     "SCGCAAA027_J10",
                     "SCGCAAA028_C07",
                     "SCGCAAA028_D10",
                     "SCGCAAA280_P20",
                     "SCGCAAA487_M09",
                     "Baikal_deep_G36",
                     "WB8_6_001",
                     "Candidatus_Fonsibacter_LSUCC0530",
                     "SCGCAAA280_B11"))

#Want to only show salinities under 32
III_low <- subset(III, Salinity < 32)

III_low$Salinity<-factor(III_low$Salinity, levels=unique(III_low$Salinity),ordered = TRUE)
III_low$SRA_accession<-factor(III_low$SRA_accession, levels=unique(III_low$SRA_accession),ordered = TRUE)
III_low <- arrange(III_low,Salinity)

#Export the dataframe, order in excel, reupload
#write.csv(III_low,"to_order.csv", row.names = FALSE)
III_low_man_sort<- read.csv("ordered.cvs", header=T)

#Subset the data based on subclades to explore individually. This is the data that contains all salinities
IIIa.1 <- subset(test_all_tile, Subclade == "IIIa.1")
IIIa.2 <- subset(test_all_tile, Subclade == "IIIa.2")
IIIa.3 <- subset(test_all_tile, Subclade == "IIIa.3")
Ia <- subset(test_all_tile, Subclade == "Ia")
Ib <- subset(test_all_tile, Subclade == "Ib")
Ic <- subset(test_all_tile, Subclade == "Ic")
II <- subset(test_all_tile, Subclade == "II")
IIIb <- subset(test_all_tile, Subclade == "IIIb")
Iabc <- subset(test_all_tile, Subclade == "Ia"|Subclade == "Ib"|Subclade == "Ic" )
III <- subset(test_all_tile, Subclade == "IIIa.1"|Subclade == "IIIa.2"|Subclade == "IIIa.3"|Subclade == "IIIb" )

#Shows all the individual subclades at all salinities for mining
ggplot(Iabc,aes(x=interaction(Salinity), y=Genome, fill=RPKM)) + 
  geom_tile()+
  scale_fill_gradientn(colours = c("white","light blue","dark blue","purple","red"),limits=c(0,46),
                       values = scales::rescale(c(0,10,20,30,45)))+
  labs(title = "Iabc", y=Iabc$Subclade ) + 
  theme(axis.text.x = element_text(angle = 90, size=5), 
        axis.text.y = element_text(size=12),
        axis.title = element_text(size=12), 
        legend.text = element_text(size=12),
        legend.title = element_text(size =12))+
  scale_y_discrete( limits = rev(levels(Iabc$Genome)))

ggplot(Ia,aes(x=interaction(Salinity), y=Genome, fill=RPKM)) + 
  geom_tile()+
  scale_fill_gradientn(colours = c("white","light blue","dark blue","purple","red"),limits=c(0,46),
                       values = scales::rescale(c(0,10,20,30,45)))+
  labs(title = "Ia" ) + 
  theme(axis.text.x = element_text(angle = 90, size=5), 
        axis.text.y = element_text(size=12),
        axis.title = element_text(size=12), 
        legend.text = element_text(size=12),
        legend.title = element_text(size =12))+
  scale_y_discrete( limits = rev(levels(Ia$Genome)))

ggplot(Ib,aes(x=interaction(Salinity), y=Genome, fill=RPKM)) + 
  geom_tile()+
  scale_fill_gradientn(colours = c("white","light blue","dark blue","purple","red"),limits=c(0,46),
                       values = scales::rescale(c(0,10,20,30,45)))+
  labs(title = "Ib") + 
  theme(axis.text.x = element_text(angle = 90, size=5), 
        axis.text.y = element_text(size=12),
        axis.title = element_text(size=12), 
        legend.text = element_text(size=12),
        legend.title = element_text(size =12))+
  scale_y_discrete( limits = rev(levels(Ib$Genome)))

ggplot(Ic,aes(x=interaction(Salinity), y=Genome, fill=RPKM)) + 
  geom_tile()+
  scale_fill_gradientn(colours = c("white","light blue","dark blue","purple","red"),limits=c(0,46),
                       values = scales::rescale(c(0,10,20,30,45)))+
  labs(title = "Ic" ) + 
  theme(axis.text.x = element_text(angle = 90, size=5), 
        axis.text.y = element_text(size=12),
        axis.title = element_text(size=12), 
        legend.text = element_text(size=12),
        legend.title = element_text(size =12))+
  scale_y_discrete( limits = rev(levels(Ic$Genome)))

ggplot(II,aes(x=interaction(Salinity), y=Genome, fill=RPKM)) + 
  geom_tile()+
  scale_fill_gradientn(colours = c("white","light blue","dark blue","purple","red"),limits=c(0,46),
                       values = scales::rescale(c(0,10,20,30,45)))+
  labs(title = "II" ) + 
  theme(axis.text.x = element_text(angle = 90, size=5), 
        axis.text.y = element_text(size=12),
        axis.title = element_text(size=12), 
        legend.text = element_text(size=12),
        legend.title = element_text(size =12))+
  scale_y_discrete( limits = rev(levels(II$Genome)))


ggplot(III_low_man_sort,aes(x=interaction(Salinity), y=Genome, fill=RPKM)) + 
  geom_tile()+
  scale_fill_gradientn(colours = c("white","light blue","dark blue","purple","red"),limits=c(0,46),
                       values = scales::rescale(c(0,10,20,30,45)))+
  labs(title = "III" ) + 
  theme(axis.text.x = element_text(angle = 90, size=5), 
        axis.text.y = element_text(size=12),
        axis.title = element_text(size=12), 
        legend.text = element_text(size=12),
        legend.title = element_text(size =12))+
  scale_y_discrete( limits = rev(levels(III$Genome)))
