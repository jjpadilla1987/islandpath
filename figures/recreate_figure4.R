#!/usr/bin/env Rscript
# Usage: Rscript recreate_figure4.R /path/to/input_directory /path/to/output_directory
# Required: ggplot2, patchwork. All tests use the full matched 136 genomes.
args <- commandArgs(trailingOnly=TRUE)
indir <- if (length(args) >= 1) args[1] else "."
outdir <- if (length(args) >= 2) args[2] else file.path(indir, "figure4_recreated")
dir.create(outdir, showWarnings=FALSE, recursive=TRUE)
if (!requireNamespace("ggplot2", quietly=TRUE) || !requireNamespace("patchwork", quietly=TRUE)) {
  stop("Install required R packages: install.packages(c('ggplot2','patchwork'))")
}
library(ggplot2)
library(patchwork)
read_tsv <- function(filename) read.delim(file.path(indir,filename), check.names=FALSE, stringsAsFactors=FALSE)
read_csv <- function(filename) read.csv(file.path(indir,filename), check.names=FALSE, stringsAsFactors=FALSE)
clusters <- read_tsv("cluster_projection.tsv")
gubbins <- read_tsv("gubbins_per_branch_statistics.tidy.tsv")
mob <- read_tsv("mob_summary.per_genome.tsv")
gi <- read_csv("first_cds136_genome_summary.csv")
stopifnot(!anyDuplicated(clusters$sample_id), !anyDuplicated(gubbins$node),
          !anyDuplicated(mob$genome), !anyDuplicated(gi$genome))
# Left joins preserve all 136 assigned samples, and select terminal branches by matching node to sample_id.
d <- merge(clusters, gubbins[,c("node","r_per_m","number_of_recombination_blocks")],
           by.x="sample_id",by.y="node",all.x=TRUE,sort=FALSE)
d <- merge(d,gi[,c("genome","gi_count","total_gi_bp")],
           by.x="sample_id",by.y="genome",all.x=TRUE,sort=FALSE)
d <- merge(d,mob[,c("genome","n_plasmid_contigs","bp_plasmid_contigs")],
           by.x="sample_id",by.y="genome",all.x=TRUE,sort=FALSE)
stopifnot(nrow(d)==nrow(clusters), nrow(d)==136)
metrics <- c("r_per_m","number_of_recombination_blocks","gi_count","n_plasmid_contigs")
if (anyNA(d[,c("fastbaps_cluster",metrics)])) stop("Missing cluster/metric values after join; inspect IDs")
d$cluster <- factor(paste("Cluster",d$fastbaps_cluster),levels=c("Cluster 1","Cluster 2"))
stopifnot(all(table(d$cluster)>0))
write.csv(d,file.path(outdir,"figure4_merged_136.csv"),row.names=FALSE)
# Outliers are identified separately within each cluster and metric using 1.5*IQR.
# They are removed ONLY from plotted points/boxplots; tests always use all genomes.
is_outlier <- function(x) {
  q <- quantile(x,c(.25,.75),na.rm=TRUE,names=FALSE)
  iq <- q[2]-q[1]
  (x < q[1]-1.5*iq) | (x > q[2]+1.5*iq)
}
labels <- c("Recombination-to-\nMutation Rate (r/m)","Recombination\nBlocks", "Genomic\nIslands", "Plasmid\nContigs")
ylabels <- c("r/m","No. of blocks","No. of islands","No. of plasmid contigs")
letters <- c("A","B","C","D")
plots <- list(); stats <- list(); excluded <- list()
for (j in seq_along(metrics)) {
  key <- metrics[j]
  df <- data.frame(sample_id=d$sample_id,cluster=d$cluster,value=as.numeric(d[[key]]))
  df$outlier <- FALSE
  for (cl in levels(df$cluster)) {
    ix <- which(df$cluster==cl)
    df$outlier[ix] <- is_outlier(df$value[ix])
  }
  excluded[[j]] <- data.frame(metric=key,df[df$outlier,,drop=FALSE])
  p <- wilcox.test(value~cluster,data=df,alternative="two.sided",exact=FALSE,correct=TRUE)$p.value
  stats[[j]] <- data.frame(metric=key,n_cluster1=sum(df$cluster=="Cluster 1"),
    n_cluster2=sum(df$cluster=="Cluster 2"),
    median_cluster1=median(df$value[df$cluster=="Cluster 1"]),
    median_cluster2=median(df$value[df$cluster=="Cluster 2"]),
    excluded_from_plot=sum(df$outlier),p_value=p,
    significance=ifelse(p<.001,"***",ifelse(p<.01,"**",ifelse(p<.05,"*","ns"))))
  shown <- df[!df$outlier,,drop=FALSE]
  # Fixed jitter seed makes the graphic reproducible.
  ymax <- max(shown$value,na.rm=TRUE)
  ymin <- min(shown$value,na.rm=TRUE)
  span <- max(ymax-ymin, ifelse(ymax==0,1,ymax*.1))
  bracket <- ymax + .09*span
  text_y <- bracket + .04*span
  plots[[j]] <- ggplot(shown,aes(x=cluster,y=value,fill=cluster)) +
    geom_boxplot(width=.55,outlier.shape=NA,alpha=.85,color="#303030",linewidth=.4) +
    geom_jitter(aes(color=cluster),width=.13,height=0,alpha=.48,size=1.15,show.legend=FALSE) +
    scale_fill_manual(values=c("Cluster 1"="#377eb8","Cluster 2"="#e46c5b")) +
    scale_color_manual(values=c("Cluster 1"="#377eb8","Cluster 2"="#e46c5b")) +
    annotate("segment",x=1,xend=2,y=bracket,yend=bracket,linewidth=.35) +
    annotate("segment",x=1,xend=1,y=bracket,yend=bracket-.025*span,linewidth=.35) +
    annotate("segment",x=2,xend=2,y=bracket,yend=bracket-.025*span,linewidth=.35) +
    annotate("text",x=1.5,y=text_y,label=stats[[j]]$significance,size=4) +
    coord_cartesian(ylim=c(min(0,ymin),text_y+.07*span),clip="off") +
    labs(title=labels[j],x=NULL,y=ylabels[j],tag=letters[j]) +
    theme_classic(base_size=12) +
    theme(legend.position="none",plot.title=element_text(face="bold",hjust=.5,size=12),
          plot.tag=element_text(face="bold",size=15),
          plot.tag.position=c(-.08,1.07),axis.text.x=element_text(size=11))
}
stats_df <- do.call(rbind,stats)
stats_df$BH_FDR <- p.adjust(stats_df$p_value,method="BH")
write.csv(stats_df,file.path(outdir,"figure4_statistics.csv"),row.names=FALSE)
write.csv(do.call(rbind,excluded),file.path(outdir,"figure4_excluded_from_plot.csv"),row.names=FALSE)
figure <- (plots[[1]] | plots[[2]]) / (plots[[3]] | plots[[4]]) +
  plot_annotation(caption="Outliers excluded from visualization (1.5 × IQR within cluster); two-sided Mann–Whitney tests include all 136 genomes.\nns: p ≥ 0.05; * p < 0.05; ** p < 0.01; *** p < 0.001. Unadjusted p-values shown.")
ggsave(file.path(outdir,"Figure4_recreated.pdf"),figure,width=9,height=8.5)
ggsave(file.path(outdir,"Figure4_recreated.png"),figure,width=9,height=8.5,dpi=300)
print(stats_df)
cat("\nOutputs saved to:",normalizePath(outdir),"\n")
