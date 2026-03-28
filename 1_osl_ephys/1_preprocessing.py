### """Preprocessing.

"""

# Authors: Chetan Gohil <chetan.gohil@psych.ox.ac.uk>

"""
import os
import re
import pathlib
from glob import glob
from dask.distributed import Client

from osl import preprocessing, utils
import mne


# Directories
BASE_DIR = "/blue/babajani.a/hsadeqi/HMM"
RAW_DIR = "/blue/babajani.a/hsadeqi/ndata11725/ndata/MEG"
PREPROC_DIR = BASE_DIR + "/preprocNINASEG"






if __name__ == "__main__":
    utils.logger.set_up(level="INFO")
   
    inputs = []
    for nina_dir in glob(os.path.join(RAW_DIR, "NINA*")):
        if ("_Less" not in nina_dir) and ("NINA035"  in nina_dir) :
    # Get all .fif files in the NINA directory
            fif_files = glob(os.path.join(nina_dir, "*.fif"))
    
            for fif_file in fif_files:
        # The subject is now the filename without extension
                raw = mne.io.read_raw_fif(fif_file, preload=True)
                current_duration = raw.times[-1]
                if current_duration > 120:
                    raw.crop(tmax=120)
                    print(f"File shortened from {current_duration:.2f} seconds to 120 seconds.")
                    raw.save(fif_file, overwrite=True)
                    print(f"Saved shortened file to: {fif_file}")
                else:
                    print(f"File is already shorter than 120 seconds. No changes made.")

                subject = pathlib.Path(fif_file).stem
        
                input_file = fif_file
                pre_file = os.path.join(PREPROC_DIR, f"/{subject}/{subject}_preproc-raw.fif")
        
                if not os.path.exists(pre_file):
                    inputs.append(input_file)
                else:
                    print(f"Skipping {subject} as it has already been processed.")

    print(f"Total files to process: {len(inputs)}")        
    # Settings
    config = """
        preproc:
        - filter: {l_freq: 0.5, h_freq: 125, method: iir, iir_params: {order: 5, ftype: butter}}
        - set_channel_types:  {EOG002: eog, EOG003: eog, ECG001: ecg}
        - notch_filter: {freqs: 60 120 180, notch_widths: 2}
        - resample: {sfreq: 250}
        - bad_segments: {segment_len: 500, picks: mag, significance_level: 0.1}
        - bad_segments: {segment_len: 500, picks: grad, significance_level: 0.1}
        - bad_segments: {segment_len: 500, picks: mag, mode: diff, significance_level: 0.1}
        - bad_segments: {segment_len: 500, picks: grad, mode: diff, significance_level: 0.1}
        - bad_channels: {picks: mag, significance_level: 0.1}
        - bad_channels: {picks: grad, significance_level: 0.1}
        - ica_raw: {picks: meg, n_components: 40}
        - ica_autoreject: {ecgmethod: 'ctps', ecgthreshold: 0.8, apply: true}
        - interpolate_bads: {}
    """
     #- set_channel_types:  {EOG061: eog, EOG062: eog, ECG063: ecg}
       # - notch_filter: {freqs: 50 100 150, notch_widths: 2}
#####  - ica_autoreject: {picks: meg, ecgmethod: correlation, eogthreshold: auto}
    # Setup parallel processing
    #client = Client(n_workers=20, threads_per_worker=1)

    # Main preprocessing
    preprocessing.run_proc_batch(
        config,
        inputs,
        outdir=PREPROC_DIR,
        overwrite=True,
        #dask_client=True,
    )