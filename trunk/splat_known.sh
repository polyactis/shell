#!/bin/sh
date
echo 'Splat, min_support 2, min_cut 3, running on yeast known genes'
cd /home/yuhuang/gph_result/known
/home/yuhuang/bin/Splat-0.1/splat gph_dataset-r 39 6456 2 3
date
