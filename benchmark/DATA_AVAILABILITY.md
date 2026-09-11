# Data availability

The benchmark was run on a prostate cancer cohort that is not publicly redistributable.

Individual-level outputs are therefore not included in this repository. Every consistency
comparison in `hpc/results/` was computed on per-individual polygenic score files holding one row
per participant (identifier, phenotype, variant counts, score) for 3140 individuals.

Those files are described in `hpc/scored_profiles_manifest.csv`, which lists for each one its
filename, SHA-256 digest, number of individuals and column layout. A reader with access to the
source cohort can regenerate the files with the commands recorded in `hpc/harness/registry_hpc.json`
and confirm the digest matches, which verifies the comparison without exposing any participant data.

Three of the files are derived rather than direct tool output. PRS-CSx, SDPRX and JointPRS emit
per-SNP posterior effects rather than individual scores, so their scores were produced from those
weights with plink 1.9.0-b.8:

    plink --bfile <target> --score <weights> 2 4 6 --allow-no-sex        # PRS-CSx, JointPRS
    plink --bfile <target> --score <weights> 1 2 3 header --allow-no-sex # SDPRX

The same plink build was used on both sides of every comparison.
