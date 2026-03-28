"""Prepare training dataset.

"""

from glob import glob

from osl_dynamics.data import Data

# Find files containing the parcel-level data
# Note, spring23 contains eyes closed resting-state data only
#files = sorted(glob("/blue/babajani.a/hsadeqi/HMM/srcCC/*/*sflip_parc-raw.fif"))
file_addresses = sorted(glob("/blue/babajani.a/hsadeqi/HMM/srcNINA/*_C_R1/*sflip_parc-raw.fif"))

#search_terms = ["NINA009" , "NINA012", "NINA018", "NINA020","NINA022","NINA026"]
search_terms = ["NINA004" , "NINA006", "NINA007", "NINA011","NINA015","NINA017", "NINA019","NINA023","NINA024","NINA025"]
filtered_addresses = [address for address in file_addresses if any(term in address for term in search_terms)]

# Load into osl-dynamics

from glob import glob
from osl_dynamics.data import Data

import pandas as pd

# Read the CSV file
df = pd.read_csv('/blue/babajani.a/hsadeqi/HMM/Demo.csv')

# Filter rows where Age > 60
filtered_df = df[df['age'] > 60]

# Get the list of Ids
ids = filtered_df['subID'].tolist()

# Convert the list of ids to a structure like [Id1, Id2, Id3]
ids_str = f"[{', '.join(map(str, ids))}]"

# Output the result
#print(ids_str)


ccfiles = sorted(glob("/blue/babajani.a/hsadeqi/HMM/srcCC/*/sub*.fif"))
ccfiles60 = [address for address in ccfiles if any(term in address for term in ids)]
ninafilesr1 = sorted(glob("/blue/babajani.a/hsadeqi/HMM/srcNINAR1/*_C_R1/NINA*.fif"))

ccnina60r1 = sorted( ccfiles60 + ninafilesr1)

data = Data(ccnina60r1, picks="misc", reject_by_annotation="omit", n_jobs=16)

# Prepare TDE-PCA data
data.prepare(
    {
        "tde_pca": {"n_embeddings": 15, "n_pca_components": 120},
        "standardize": {},
    }
)

# Save a TFRecord dataset
data.save_tfrecord_dataset("/blue/babajani.a/hsadeqi/HMM/ccnina60r1_training_dataset", sequence_length=400)

# Delete temporary directory
data.delete_dir()
