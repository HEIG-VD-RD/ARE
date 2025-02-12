#!/bin/bash

python3 pgm_fpga.py -s=../eda/output_files/DE1_SoC_top.sof
python3 upld_hps.py -a=../../soft/proj/hps_temps_reaction/Debug/hps_temps_reaction.axf
