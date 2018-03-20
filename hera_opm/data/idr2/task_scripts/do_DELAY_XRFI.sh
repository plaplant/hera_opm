#! /bin/bash
set -e

# import common functions
src_dir="$(dirname "$0")"
source ${src_dir}/_common.sh

# define polarizations
pol1="xx"
pol2="yy"

# make the file name
bn=$(basename ${1})

# We run a delay filter, then xrfi on the data visibilities for all polarizations.
# We assume xrfi has already been run on the model visibilities, abscal gain solutions,
# and omnical chi-squared values. These flags are applied to the data before the
# delay filter in delay_xrfi_run.py.
#
# Once the flagging is done, we need to tie everything together, and broadcast/apply to the
# data files. This is done in the `do_DELAY XRFI_APPLY.sh' script, which will take all of the
# *.npz files as arguments in addition to the flags generated by flagging the raw visibilities.

# Parameters are set in the configuration file, here we define their positions,
# which must be consistent with the config. See hera_qm.utils for details.
# 1 - filename
# 2 - bad_ants_dir
### Delay filter parameters
# 3 - standoff
# 4 - horizon
# 5 - tol
# 6 - window
# 7 - skip_wgt
# 8 - maxiter
# 9 - kt_size
# 10 - kf_size
# 11 - sig_init
# 12 - sig_adj
# 13 - px_threshold
# 14 - freq_threshold
# 15 - time_threshold

# Get list of bad ants
jd=$(get_jd ${bn})
jd_int=`echo $jd | awk '{$1=int($1)}1'`
bad_ants_fn=`echo "${2}/${jd_int}.txt"`
exants=$(prep_exants ${bad_ants_fn})

# get waterfalls
base_xx=$(replace_pol ${bn} ${pol1})
base_yy=$(replace_pol ${bn} ${pol2})
vis_wf_xx=`echo ${base_xx}.vis.uvfits.flags.npz`
vis_wf_yy=`echo ${base_yy}.vis.uvfits.flags.npz`
# get chisq waterfall
chi_wf_xx=`echo ${base_xx}.abs.calfits.x.flags.npz`
chi_wf_yy=`echo ${base_yy}.abs.calfits.x.flags.npz`
# get gains waterfall
g_wf_xx=`echo ${base_xx}.abs.calfits.g.flags.npz`
g_wf_yy=`echo ${base_yy}.abs.calfits.g.flags.npz`
# make big list of waterfalls
wf_list=$(join_by , ${vis_wf_xx} ${vis_wf_yy} ${chi_wf_xx} ${chi_wf_yy} ${g_wf_xx} ${g_wf_yy})


# Run just on visibilities
echo delay_xrfi_run.py --standoff=${3} --horizon=${4} --tol=${5} --window=${6} --skip_wgt=${7} --maxiter=${8} --kt_size=${9} --kf_size=${10} --sig_init=${11} --sig_adj=${12} --px_threshold=${13} --freq_threshold=${14} --time_threshold=${15} --exants=${exants} --infile_format=miriad --algorithm=xrfi --extension=.flags.npz --summary --waterfalls=${wf_list} ${bn}OC
delay_xrfi_run.py --standoff=${3} --horizon=${4} --tol=${5} --window=${6} --skip_wgt=${7} --maxiter=${8} --kt_size=${9} --kf_size=${10} --sig_init=${11} --sig_adj=${12} --px_threshold=${13} --freq_threshold=${14} --time_threshold=${15} --exants=${exants} --infile_format=miriad --algorithm=xrfi --extension=.flags.npz --summary --waterfalls=${wf_list} ${bn}OC
