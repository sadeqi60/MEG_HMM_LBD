from osl import source_recon, utils
from dask.distributed import Client

if __name__ == "__main__":
    utils.logger.set_up(level="INFO")

    # Copy coreg directory
    if not os.path.exists(SRC_DIR):
        cmd = f"cp -r {COREG_DIR} {SRC_DIR}"
        print(cmd)
        os.system(cmd)

    subjects = []
    for subject in sorted(glob(RAW_FILE.replace("{0}", "*"))):
        subject_name = pathlib.Path(subject).stem
        if "NINA033" not in subject_name:
            continue
        subjects.append(pathlib.Path(subject).stem)
    # Setup files
    preproc_files = []
    for subject in subjects:
        preproc_files.append(PREPROC_FILE.format(subject))

    # Settings
    config = """
        source_recon:
        - forward_model:
            model: Single Layer
        - beamform_and_parcellate:
            freq_range: [1, 80]
            chantypes: [mag, grad]
            rank: {meg: 60}
            parcellation_file: Glasser52_binary_space-MNI152NLin6_res-8x8x8.nii.gz
            method: spatial_basis
            orthogonalisation: symmetric
    """
    source_recon.run_src_batch(
        config,
        outdir=SRC_DIR,
        subjects=subjects,
        preproc_files=preproc_files,
    )
