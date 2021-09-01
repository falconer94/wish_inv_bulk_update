library(tidyverse)



# Filter products with <10 inv on Wish
wish_inv <- read.csv("wish_inv.csv")
wish_inv <- wish_inv %>%
  rename(wish_inv = Inventory) %>% 
  select(SKU, wish_inv) %>% 
  filter(wish_inv < 10)

#### In stock ####

# Filter products with >100 from esupp UT
esupp <- read.csv("core_product_report.csv")
esupp <- esupp %>% 
  rename(SKU = prod_sku)

stk <- esupp %>% 
  select(SKU, UT.Inv) %>% 
  filter(UT.Inv > 100) 

# Join stk to wish_inv 
stk2 <- left_join(wish_inv, stk) %>% 
  na.omit()

# Set Wish inv to 10% of UT inv 

stk2 <- stk2 %>% 
  mutate(Quantity = round(0.1*UT.Inv)) %>% 
  select(SKU, Quantity)


#### OOS ####

## set to 0 if UT inv <20

# Filter inv <20
oos <- esupp %>% 
  select(SKU, UT.Inv) %>% 
  filter(UT.Inv < 20)

# Join oos to wish_inv
oos2 <- left_join(wish_inv, oos) %>% 
  na.omit()

# Set Wish inv to 0 if oos 

oos2 <- oos2 %>% 
  mutate(Quantity = 0) %>% 
  select(SKU, Quantity)



# join stk2 and oos2
update <- full_join(stk2, oos2)





#### Remove Prohibited Products ####
# yohimbine, yohimbe bark, dhea, and pregnenolone

prohibited <- read.csv("prohibited.csv")

update[update$SKU %in% prohibited$SKU,]

update2 <- update[!update$SKU %in% prohibited$SKU,]







#### Template ####
# # Upload temp
# temp <- read.csv("Wish_Upload_Inv_Temp.csv")
# names(temp)
# temp <- rename(temp, SKU = Unique.ID)
# 
# # set temp columns to character, num
# temp <- temp %>% 
#   mutate_if(is.logical, as.character) %>% 
#   transform(Quantity = as.numeric(Quantity))
# 
# # Join to temp
# update2 <- full_join(update, temp) %>% 
#   select(SKU, Quantity)

#### Export ####
write.csv(update2, "wish_inv_update.csv", row.names = FALSE)


