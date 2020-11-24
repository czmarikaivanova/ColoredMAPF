#!/usr/bin/awk -f

FNR=1{outfile="new"FILENAME; print NR > outfile}
FNR>1{print $0 >> outfile}

