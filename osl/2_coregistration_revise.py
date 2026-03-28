from osl import source_recon, utils


def fix_headshape_points(outdir, subject, preproc_file, smri_file, epoch_file):
    filenames = source_recon.rhino.get_coreg_filenames(outdir, subject)
    hs = np.loadtxt(filenames["polhemus_headshape_file"])
    nas = np.loadtxt(filenames["polhemus_nasion_file"])
    lpa = np.loadtxt(filenames["polhemus_lpa_file"])
    rpa = np.loadtxt(filenames["polhemus_rpa_file"])
    nas[2] -= 40
    distances = np.sqrt(
        (nas[0] - hs[0]) ** 2 + (nas[1] - hs[1]) ** 2 + (nas[2] - hs[2]) ** 2
    )
    keep = distances > 70
    hs = hs[:, keep]
    keep = hs[0] < rpa[0]
    hs = hs[:, keep]
    keep = hs[0] > lpa[0]
    hs = hs[:, keep]
    remove = hs[2] < min(lpa[2], rpa[2]) - 4
    hs = hs[:, ~remove]
    utils.logger.log_or_print(f"overwritting {filenames['polhemus_headshape_file']}")
    np.savetxt(filenames["polhemus_headshape_file"], hs)


if __name__ == "__main__":
    # Settings
    config = """
        source_recon:
        - extract_polhemus_from_info: {}
        - fix_headshape_points: {}
        - compute_surfaces:
            include_nose: False
        - coregister
            use_nose: False
            use_headshape: True
            n_init: 1
    """
    source_recon.run_src_batch(
        config,
        outdir=COREG_DIR,
        subjects=subjects,
        preproc_files=preproc_files,
        smri_files=smri_files,
        extra_funcs=[fix_headshape_points],
    )
