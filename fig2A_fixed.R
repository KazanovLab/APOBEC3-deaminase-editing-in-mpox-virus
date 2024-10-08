#author: "Lyskova_Alisa"
#date: "2024-08-31"

library(tidyverse)
library(showtext)
library(showtextdb)
showtext_auto()
#font_add_google("Roboto Condensed")

pink <- '#C6878F'
brown <- '#E07A5F'
blue <- '#3D405B'
green1 <- '#5F797B'
green2 <- '#81B29A'
yellow <- '#F2CC8F'

file1 <- c("data/B1_data_fixed_APOBEC.csv")
file2 <- c("data/APOBEC_targets_aa.csv")
df1 <- read.csv(file1, sep = "\t", header = TRUE)
df2 <- read.csv(file2, sep = "\t", header = TRUE)
df1 <- df1 %>% mutate(type = "APOBEC3-like mutations")
df2 <- df2 %>% mutate(type = "TC or GA target site")

targets_cnt <- nrow(df2)
muts_cnt <- nrow(df1)

print("Number of potential sites: ")
print(targets_cnt)

print("Number of observed APOBEC3-like sites: ")
print(muts_cnt)

df <- rbind(df1,df2)
df$type <- factor(df$type, levels=c("TC or GA target site","APOBEC3-like mutations"))
df_grouped <- df %>% group_by(mutation_category, type) %>% summarise(number = n())
df_grouped <- df_grouped %>% mutate(share = case_when(
  type == "TC or GA target site" ~ number/targets_cnt,
  type == "APOBEC3-like mutations" ~ number/muts_cnt,
))
df_grouped

p <- ggplot(df_grouped, aes(x=factor(mutation_category, level = c('nonsynonymous', 'synonymous', 'nonsense', 'intergenic')), y=share, fill=type)) + 
  geom_bar(stat = "identity", position=position_dodge()) +
  scale_fill_manual(values=c(blue,brown))+
  geom_text(aes(label=number), vjust=-0.3, color="black",
            position = position_dodge(0.9), size=8)+
  theme_bw() +
  labs(title= 'Number of APOBEC targets and observed APOBEC3-like sites by mutation category',
      x = 'Mutation type',
      y = 'Proportion') +
    theme(text=element_text(size=24, family="Roboto Condensed"),
        plot.title = element_text(hjust = 0.5, size = 24),
        axis.text=element_text(size=24))

ggsave('plots/fig2A_fixed.png', plot = p, height=4, width=5, dpi=300)
