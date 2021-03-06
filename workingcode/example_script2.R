rm(list = ls())

library(dplyr)
library(OpenMx)
library(xtable)
library(umx)

data_orig <- read.csv(file = "C:/Users/Besitzer/Documents/Arbeit/Twinlife/Artikel/Netzwerke/Git/netzwerke/Update/data_wide.csv",
                      header = TRUE)
summary(data_orig)

# create binary variable
data_orig <- data_orig %>% mutate(schoolb_1 = ifelse(schoolhigh_1 <= 2, 1,
                                                     ifelse(schoolhigh_1 >= 3, 2, NA))) %>% 
    mutate(schoolb_2 = ifelse(schoolhigh_2 <= 2, 1,
                                                     ifelse(schoolhigh_2 >= 3, 2, NA))) %>% 
    mutate(kukabin_1 = ifelse(kultkapjahre_1 >= median(kultkapjahre_1, na.rm = TRUE),1,
                              ifelse(kultkapjahre_1 < median(kultkapjahre_1, na.rm = TRUE),2,NA))) %>% 
    mutate(kukabin_2 = ifelse(kultkapjahre_2 >= median(kultkapjahre_1, na.rm = TRUE),1,
                              ifelse(kultkapjahre_2 < median(kultkapjahre_1, na.rm = TRUE),2,NA)))

mz_data <- data_orig %>% filter(zyg ==1) 
dz_data <- data_orig %>% filter(zyg ==2)
ovars <- c("schoolhigh_1","schoolhigh_2","schoolb_1","schoolb_2","kukabin_1","kukabin_2")
mz_data[,ovars] <- umxFactor(mz_data[,ovars])
dz_data[,ovars] <- umxFactor(dz_data[,ovars])

# load twinflex function
source("C:/Users/Besitzer/Documents/Arbeit/Twinlife/twinflex/Git/twinflex.R")


# univariate ACE model with continuous DV
    # twinflex
tf_uni_c <- twinflex(acevars = "posbez",data = data_orig,sep = "_",zyg = "zyg") ## works fine
    # umx
umx_uni_c <- umxACE(selDVs = "posbez", dzData = dz_data, mzData = mz_data, sep = "_")
    # comparison
tf_uni_c[["ModelSummary"]] # -2LL = 8642.8438
summary(umx_uni_c)         # -2LL = 8642.8438

# univariate ACE model with ordinal DV
    # twinflex
tf_uni_o <- twinflex(acevars = "schoolhigh",ordinal = "schoolhigh",data = data_orig,sep = "_",zyg = "zyg") ## works fine
    # umx
umx_uni_o <- umxACE(selDVs = "schoolhigh", dzData = dz_data, mzData = mz_data, sep = "_")
    # comparison
tf_uni_o[["ModelSummary"]] # -2LL = 5853.9736
summary(umx_uni_o)         # -2LL = 5853.9736


# univariate ACE model with binary DV
    # twinflex
tf_uni_b <- twinflex(acevars = "schoolb",ordinal = "schoolb",data = data_orig,sep = "_",zyg = "zyg") ## works fine
    # umx
umx_uni_b <- umxACE(selDVs = "schoolb", dzData = dz_data, mzData = mz_data, sep = "_")
    # comparison
tf_uni_b[["ModelSummary"]] # -2LL = 3153.1204
summary(umx_uni_b)         # -2LL = 3153.1204

# bivariate ACE model ("Cholesky") with only continuous variables
    # twinflex
tf_bi_cc <- twinflex(acevars = c("posbez","negbez"),data = data_orig,sep = "_",zyg = "zyg") ## works fine
    # umx
umx_bi_cc <- umxACE(selDVs = c("posbez","negbez"), dzData = dz_data, mzData = mz_data, sep = "_")
    # comparison
tf_bi_cc[["ModelSummary"]] # -2LL = 17006.44
summary(umx_bi_cc)         # -2LL = 17006.44

# bivariate ACE model ("Cholesky") with continuous and ordinal variables
    # twinflex
tf_bi_co <- twinflex(acevars = c("schoolhigh","posbez"),ordinal = "schoolhigh",data = data_orig,sep = "_",zyg = "zyg") ## works fine
    # umx
umx_bi_co <- umxACE(selDVs = c("schoolhigh","posbez"), dzData = dz_data, mzData = mz_data, sep = "_")
    # comparison
tf_bi_co[["ModelSummary"]] # -2LL = 14459.13
summary(umx_bi_co)         # -2LL = 14459.13

# bivariate ACE model ("Cholesky") with continuous and binary variables
    # twinflex
tf_bi_cb <- twinflex(acevars = c("schoolb","posbez"),ordinal = "schoolb",data = data_orig,sep = "_",zyg = "zyg") ## works fine
    # umx
umx_bi_cb <- umxACE(selDVs = c("schoolb","posbez"), dzData = dz_data, mzData = mz_data, sep = "_")
    # comparison
tf_bi_cb[["ModelSummary"]] # -2LL = 11767.31
summary(umx_bi_cb)         # -2LL = 11767.31

# bivariate ACE model ("Cholesky") with two binary variables
    # twinflex
tf_bi_bb <- twinflex(acevars = c("schoolb","kukabin"),ordinal = c("schoolb","kukabin"),data = data_orig,sep = "_",zyg = "zyg") ## works fine
    # umx
umx_bi_bb <- umxACE(selDVs = c("schoolb","kukabin"), dzData = dz_data, mzData = mz_data, sep = "_")
    # comparison
tf_bi_bb[["ModelSummary"]] # -2LL = 6529.205
summary(umx_bi_bb)         # -2LL = 6529.205


###               ###
# Moderation models #
###               ###

# univariate GxE with constant moderator and continuous DV
    # twinflex
gxe1 <- data_orig %>% filter(!is.na(age))
tf_modu_c <- twinflex(acevars = c("posbez"),data = gxe1,sep = "_",zyg = "zyg", modACEuniv = "posbez BY age", tryHard = TRUE) ## works fine
gxe11 <- data_orig %>% filter(!is.na(posbez_1) & !is.na(posbez_2))
gxe11$posbez_1 <- scale(gxe11$posbez_1)
gxe11$posbez_2 <- scale(gxe11$posbez_2)
selfmod <- twinflex(acevars = c("posbez"),data = gxe11,sep = "_",zyg = "zyg", modACEuniv = "posbez BY posbez", tryHard = TRUE, exh = FALSE) ## works fine
selfmod[["ModelSummary"]]
    # umx
mzgxe1 <- mz_data %>% filter(!is.na(age)) %>% mutate(age_1 = age) %>% mutate(age_2 = age) %>% select(posbez_1,posbez_2,age_1,age_2) 
dzgxe1 <- dz_data %>% filter(!is.na(age)) %>% mutate(age_1 = age) %>% mutate(age_2 = age) %>% select(posbez_1,posbez_2,age_1,age_2) 
umx_modu_c <- umxGxE(selDVs = c("posbez"), selDefs = "age",dzData = dzgxe1, mzData = mzgxe1, sep = "_", lboundACE = 1e-04, tryHard = "search")
umx_modu_c <- umxModify(umx_modu_c, update = "quad11")
    # comparison
tf_modu_c[["ModelSummary"]] # -2LL = 8575.396
summary(umx_modu_c)         # -2LL = 8575.396

# bivariate GxE
    # twinflex
gxe2 <- data_orig %>% filter(!is.na(posbez_1) & !is.na(posbez_2))
tf_modb_c <- twinflex(acevars = c("posbez","negbez"),data = gxe2,sep = "_",zyg = "zyg", modACEuniv = "negbez BY posbez",modACEbiv = "posbez -> negbez BY posbez") ## works fine
    # umx
mzgxe2 <- mz_data %>% filter(!is.na(posbez_1) & !is.na(posbez_2)) %>% select(posbez_1,posbez_2,negbez_1,negbez_2) 
dzgxe2 <- dz_data %>% filter(!is.na(posbez_1) & !is.na(posbez_2)) %>% select(posbez_1,posbez_2,negbez_1,negbez_2) 
umx_modu_c <- umxGxEbiv(selDVs = c("negbez"), selDefs = "posbez",dzData = dzgxe2, mzData = mzgxe2, sep = "_")
    # comparison
tf_modu_c[["ModelSummary"]] # -2LL = 16922.94
summary(umx_modu_c)         # -2LL = 18586.38





    # twinflex
source("C:/Users/Besitzer/Documents/Arbeit/Twinlife/twinflex/Git/twinflex.R")
tf_uni_c_cc <- twinflex(acevars = c("posbez","negbez"),covvars = c("age","iseiempmean"),
                        data = data_orig,sep = "_",
                        zyg = "zyg", tryHard = TRUE) ## works fine
    # umx
umx_uni_c_cc <- umxACEcov(selDVs = "posbez", selCovs = c("iseiempmean", dzData = dz_data, mzData = mz_data, sep = "_")
    # comparison ACE estimates identical despite minor differences in parametrization
tf_uni_c_cc[["ModelSummary"]] # -2LL = 27529.93
summary(umx_uni_c_cc) # 27530.6




