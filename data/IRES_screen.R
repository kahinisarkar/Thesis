library(tidyverse)
library(openxlsx)
library(ggpubr)

raw = read.xlsx("data/plate1ratios11518.xlsx")
long = raw %>% 
  pivot_longer(cols = -Gene, names_to = "Replicate", values_to = "normalized_ratio", values_drop_na = TRUE)
long

replicated = long %>% 
  group_by(Gene) %>% 
  add_count() %>% 
  filter(n > 2) %>% 
  mutate(median_normalized_ratio = median(normalized_ratio)) %>% 
  arrange(median_normalized_ratio)

cat(paste(shQuote(unique(replicated$Gene), type="cmd"), collapse=", "))

gene_order = c("CTRL", "Rps25", "TKV", "Bam", "Polybromo", "faf", "caf1 ", "Set8", "CG4747", "nsl-1", "Sxc", "Jarid2", "Lsd1", 
               "comr", "Trr", "CG10289", "HDAC3", "Not", "Gpp", "Art8", "CG2051", "Su(var)205", 
               "S6KII (1)", "Gcn5 (33981)", "D12", "CG7376", "wda", "Sgf29", "Enok", 
               "Tip60", "Su(z)12", "S6K", "Set1", "Ada3", "chm", "E(z) sm", "Atac2", "LRRK")

replicated$Gene = factor(replicated$Gene, levels = gene_order)

stat_test = compare_means(normalized_ratio ~ Gene,  data = replicated,
              ref.group = "CTRL", method = "t.test")

significant_genes = stat_test %>% filter(p.signif != "ns") %>% pull(group2)


replicated$Significant = "Not significant"
replicated$Significant[replicated$Gene %in% significant_genes] = "Significant"

ggboxplot(replicated, x = "Gene", y = "normalized_ratio",
            desc_stat = "mean_sd", color = "black", fill="Significant")+
  xlab("RNAi target gene")+
  geom_hline(yintercept = 1, linetype='dashed', col = 'grey40')+
  ylab("Relative IRES translation (Firefly/Renilla A.U.)")+
  fill_palette(c("grey50", "palegreen"))+
  stat_compare_means(label = "p.signif", method = "t.test",
                   ref.group = "CTRL")+                   # Pairwise comparison against CTRL
  coord_flip()

ggsave("data/IRES_screen.png", width = 7, height = 10)

replicated %>% filter(Significant == "Significant") %>% summarise(unique(Gene))
replicated %>% filter(Gene == "Set8")
replicated %>% filter(Gene == "Bam")

all_RNAi_lines = read.xlsx("data/All_Alicia_RNAi_lines.xlsx")
match = all_RNAi_lines %>% filter(Protein %in% gene_order)
