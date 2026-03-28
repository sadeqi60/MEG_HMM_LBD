# MEG LBD Dynamic Connectivity — Analysis Code

[![DOI](https://zenodo.org/badge/DOI/your-doi-here.svg)](https://doi.org/your-doi-here)  
**Repository for the manuscript:**  
**Dynamic, State-dependent Characteristics of Cognitive Fluctuations in Lewy Body Dementia: A MEG Study**  
*(Sadeqi et al., 2026 — submitted to Brain Communications)*

## Research Pipeline (Step-by-Step)

1. **MEG Data Acquisition & Preprocessing**  
   - Raw MEG data (Elekta/MEGIN TRIUX + CamCAN)  
   - Temporal signal-space separation (tSSS) with MaxFilter  
   - **Preprocessing performed with `osl-ephys`** (Oxford Centre for Human Brain Activity Software Library for Electrophysiology)  
   - Band-pass filtering, ICA artifact removal (CTPS), bad segment rejection, downsampling to 250 Hz, and extraction of 120 s artifact-free eyes-closed data per session.

2. **Source Reconstruction & Parcel Time Series**  
   - LCMV beamforming (1–80 Hz)  
   - Projection onto Glasser 52 cortical parcels (MNI152, 8 mm) with symmetric orthogonalization to reduce leakage.

3. **Dynamic Functional Connectivity with Hidden Markov Modeling**  
   - **Time-delay embedded HMM (TDE-HMM) performed with `osl-dynamics`**  
   - 15 lags (~60 ms), PCA to 120 components, K = 6 states  
   - Training on concatenated data from all participants (UF + CamCAN normative cohort)  
   - Extraction of fractional occupancy (FO), mean lifetime, and state time courses.

4. **State-Resolved Spectral Analysis**  
   - Multitaper power spectral density (PSD) per state and parcel  
   - Theta/beta ratio (TBR) calculation  
   - Group comparisons (LBD vs. PD vs. NC) and sensitivity analyses (global power covariate).

5. **Statistical Analyses & Visualization**  
   - Nonparametric permutation tests and Spearman correlations (5,000 permutations)  
   - **All statistical visualizations and brain-surface maps generated in R** using `ggseg` and custom `geom_brain` functions.

## Software & Citations

### Core Toolboxes

- **osl-ephys** — preprocessing and source reconstruction  
  van Es, M. W. J., et al. (2025). *osl-ephys: a Python toolbox for the analysis of electrophysiology data*. Frontiers in Neuroscience.
  https://doi.org/10.3389/fnins.2025.1522675   
  Documentation: [osl-ephys.readthedocs.io](https://osl-ephys.readthedocs.io/)  
  GitHub:[https://github.com/OHBA-analysis/osl-ephys](https://github.com/OHBA-analysis/osl-ephys)

- **osl-dynamics** — TDE-HMM and dynamic network analysis  
  Gohil, C., Huang, R., Roberts, E., van Es, M. W., Quinn, A. J., Vidaurre, D., & Woolrich, M. W. (2024). *osl-dynamics, a toolbox for modeling fast dynamic brain activity*. eLife, 12, RP91949.  
  https://doi.org/10.7554/eLife.91949  
  Documentation: [https://osl-dynamics.readthedocs.io/en/latest/](https://osl-dynamics.readthedocs.io/en/latest/)    
  GitHub: [github.com/OHBA-analysis/osl-dynamics](https://github.com/OHBA-analysis/osl-dynamics)

### Visualization

- **ggseg** (R package) — brain surface mapping  
  Mowinckel, A. M., & Vidal-Piñeiro, D. (2020). Visualisation of Brain Statistics with R-packages ggseg and ggseg3d. *Advances in Methods and Practices in Psychological Science*.  
  https://doi.org/10.1177/2515245920928009    
  CRAN: [cran.r-project.org/package=ggseg](https://cran.r-project.org/package=ggseg)

