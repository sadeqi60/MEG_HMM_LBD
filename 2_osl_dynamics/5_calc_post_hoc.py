"""Post-hoc analysis.

"""

import os
from sys import argv


if len(argv) != 2:
    print("Please pass the number of states and run id, e.g. python 5_calc_post_hoc.py 8")
    exit()

n_states = int(argv[1])

output_dir = f"/blue/babajani.a/hsadeqi/HMM/resultsCC/inf_params/{n_states:02d}_states_ccnina60r1"

import pickle
import numpy as np
from glob import glob

from osl_dynamics.data import Data
from osl_dynamics.inference import modes
from osl_dynamics.analysis import spectral
import pandas as pd
# Load parcellated data
files = sorted(glob("/blue/babajani.a/hsadeqi/HMM/srcNINA/*_C_R1/*sflip_parc-raw.fif"))#[:20]

file_addresses = sorted(glob("/blue/babajani.a/hsadeqi/HMM/srcNINA/*_C_R1/*sflip_parc-raw.fif"))

#search_terms = ["NINA001" , "NINA002", "NINA003", "NINA013","NINA016","NINA021"]
#search_terms = ["NINA009" , "NINA012", "NINA018", "NINA020","NINA022","NINA026"]
search_terms = ["NINA004" , "NINA006", "NINA007", "NINA011","NINA015","NINA017", "NINA019","NINA023","NINA024","NINA025"]

filtered_addresses = [address for address in file_addresses if any(term in address for term in search_terms)]


df = pd.read_csv('/blue/babajani.a/hsadeqi/HMM/Demo.csv')

# Filter rows where Age > 60
filtered_df = df[df['age'] > 60]

# Get the list of Ids
ids = filtered_df['subID'].tolist()

# Convert the list of ids to a structure like [Id1, Id2, Id3]
ids_str = f"[{', '.join(map(str, ids))}]"

# Output the result
#print(ids_str)



#ccfiles = sorted(glob("/blue/babajani.a/hsadeqi/HMM/srcCC/*/sub*.fif"))
#ccfiles60 = [address for address in ccfiles if any(term in address for term in ids)]
#ninafiles = sorted(glob("/blue/babajani.a/hsadeqi/HMM/srcNINAR1/*_C_R1/NINA*.fif"))

#ccnina60 = sorted( ccfiles60 + ninafiles)


#data = Data(filtered_addresses, picks="misc", reject_by_annotation="omit", n_jobs=16)
#data = Data(ccnina60, picks="misc", reject_by_annotation="omit", n_jobs=16)


ccfiles = sorted(glob("/blue/babajani.a/hsadeqi/HMM/srcCC/*/sub*.fif"))
ccfiles60 = [address for address in ccfiles if any(term in address for term in ids)]
ninafilesr1 = sorted(glob("/blue/babajani.a/hsadeqi/HMM/srcNINAR1/*_C_R1/NINA*.fif"))

ccnina60r1 = sorted( ccfiles60 + ninafilesr1)

data = Data(ccnina60r1, picks="misc", reject_by_annotation="omit", n_jobs=16)
data.save("training_data/networks")

x = data.trim_time_series(n_embeddings=15, sequence_length=400)

# Load state probability time courses
alp = pickle.load(open(f"{output_dir}/alp.pkl", "rb"))

# Calculate multitaper spectra
f, psd, coh, w = spectral.multitaper_spectra(
    data=x,
    alpha=alp,
    sampling_frequency=250,
    time_half_bandwidth=4,
    n_tapers=7,
    frequency_range=[1, 45],
    standardize=True,
    return_weights=True,
    n_jobs=16,
)
np.save(f"{output_dir}/f.npy", f)
np.save(f"{output_dir}/psd.npy", psd)
np.save(f"{output_dir}/coh.npy", coh)
np.save(f"{output_dir}/w.npy", w)

# Calculate non-negative matrix factorisation on the stacked coherences
nnmf = spectral.decompose_spectra(coh, n_components=2)
np.save(f"{output_dir}/nnmf_2.npy", nnmf)

# Convert probabilities to a state time course
stc = modes.argmax_time_courses(alp)

# Calculate subject-specific summary stats
fo = modes.fractional_occupancies(stc)
lt = modes.mean_lifetimes(stc, sampling_frequency=250)
intv = modes.mean_intervals(stc, sampling_frequency=250)
sr = modes.switching_rates(stc, sampling_frequency=250)
np.save(f"{output_dir}/fo.npy", fo)
np.save(f"{output_dir}/lt.npy", lt)
np.save(f"{output_dir}/intv.npy", intv)
np.save(f"{output_dir}/sr.npy", sr)

# Delete temporary directory
data.delete_dir()
