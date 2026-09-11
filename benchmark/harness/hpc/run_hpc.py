#!/usr/bin/env python3
"""Obj1 on HPC: run one tool/replicate under Apptainer via Slurm.
Recipes come verbatim from the laptop registry (paths rewritten for this box).

Execution runs from a pre-extracted SANDBOX, not the .sif: on this node apptainer
mounts a .sif through squashfuse (FUSE), which times out under sustained load and
makes the container filesystem vanish mid-run. Docker on the laptop also executes
from unpacked layers, so a sandbox is the closer analogue anyway. Pull time and
sandbox-extraction time are recorded separately so neither is hidden.
"""
import json, os, re, subprocess, sys, time, hashlib, shutil

BOX = os.path.expanduser("~/obj1_hpc")
REG = json.load(open(f"{BOX}/harness/registry_hpc.json"))
ENV = {"OMP_NUM_THREADS":"4","OPENBLAS_NUM_THREADS":"4","MKL_NUM_THREADS":"4",
       "NUMEXPR_NUM_THREADS":"4","LC_ALL":"C","LANG":"C"}
# Tools whose R/OpenBLAS path is runtime CPU-dispatched. The reference numbers came
# from a Kaby Lake laptop (AVX2); this node is Cascade Lake (AVX-512), so OpenBLAS
# picks a different GEMM kernel and the last bit of each value changes. Pinning the
# kernel restores byte-identical output. Costs about 10 percent of the speed.
PIN = {"xpass": "HASWELL", "xpass+": "HASWELL"}
MEM = {"default":"32G"}
TLIM = {"bridgeprs":"12:00:00","ctsleb":"12:00:00","prscsx_gw":"12:00:00",
        "jointprs_gw":"12:00:00","sdprx_gw":"12:00:00","default":"04:00:00"}

def subst(s, vars_, out):
    s = s.replace("{DOCKER_OUT}", out)
    for k, v in vars_.items():
        s = s.replace("{"+k+"}", str(v))
    return s

def sha256(p):
    h = hashlib.sha256()
    with open(p,"rb") as f:
        for b in iter(lambda: f.read(1<<20), b""): h.update(b)
    return h.hexdigest()

def run(tool, rep):
    spec = REG[tool]
    tag  = tool.replace('+','plus')
    out  = f"{BOX}/runs/{tool}/rep{rep}"
    shutil.rmtree(out, ignore_errors=True); os.makedirs(out, exist_ok=True)
    sif  = f"{BOX}/containers/{tag}.sif"
    sbx  = f"{BOX}/containers/{tag}_sandbox"

    res = {"tool":tool,"rep":rep}

    # ---- SETUP: cold pull (the docker-pull analogue) ----
    if os.path.exists(sif): os.remove(sif)
    shutil.rmtree(sbx, ignore_errors=True)
    subprocess.run("rm -rf ~/.apptainer/cache/*", shell=True)
    t0 = time.time()
    p = subprocess.run(["apptainer","pull","--force",sif,f"docker://{spec['image']}"],
                       capture_output=True, text=True)
    res["pull_s"] = round(time.time()-t0, 2)
    if p.returncode != 0:
        res.update({"exit":p.returncode,"phase":"pull","err":p.stderr[-400:]}); return res

    # ---- extract sandbox (recorded separately, not folded into setup) ----
    t0 = time.time()
    p = subprocess.run(["apptainer","build","--force","--sandbox",sbx,sif],
                       capture_output=True, text=True)
    res["sandbox_s"] = round(time.time()-t0, 2)
    if p.returncode != 0:
        res.update({"exit":p.returncode,"phase":"sandbox","err":p.stderr[-400:]}); return res

    # ---- EXEC ----
    vars_ = spec["vars"]
    binds = []
    for m in spec["mounts"]:
        binds += ["--bind", subst(m, vars_, out)]
    binds += ["--bind","/data/harvard_dataverse/ld_ref:/data/harvard_dataverse/ld_ref"]
    cmdfile = f"{out}/cmd.sh"
    open(cmdfile,"w").write(subst(spec["cmd"], vars_, out) + "\n")
    binds += ["--bind", f"{cmdfile}:/work/cmd.sh"]
    # GNU time: prefer the image's own; otherwise bind the copy extracted from
    # chiomab/prsice:v1.0 (glibc 2.31, so it loads on every newer image).
    # MaxRSS comes from getrusage either way, so the measurement is the same.
    if os.path.exists(f"{sbx}/usr/bin/time"):
        timebin = "/usr/bin/time"; res["time_src"] = "image"
    else:
        binds += ["--bind", f"{BOX}/harness/gnu_time:/usr/local/bin/time"]
        timebin = "/usr/local/bin/time"; res["time_src"] = "extracted"

    envargs = []
    env = dict(ENV)
    if tool in PIN:
        env["OPENBLAS_CORETYPE"] = PIN[tool]
    res["openblas_coretype"] = env.get("OPENBLAS_CORETYPE", "auto")
    for k,v in env.items(): envargs += ["--env", f"{k}={v}"]

    # Already inside an sbatch allocation -> run directly. Otherwise wrap in srun
    # so an ad-hoc invocation still gets a memory reservation.
    if os.environ.get("SLURM_JOB_ID"):
        srun = []
    else:
        srun = ["srun","--partition=workshop","--cpus-per-task=4",
                f"--mem={MEM.get(tool, MEM['default'])}",
                f"--time={TLIM.get(tool, TLIM['default'])}"]
    app  = ["apptainer","exec","--cleanenv"] + envargs + binds + [sbx,
            timebin,"-v","bash","/work/cmd.sh"]
    with open(f"{out}/run.out","w") as so, open(f"{out}/run.err","w") as se:
        res["exit"] = subprocess.run(srun+app, stdout=so, stderr=se).returncode

    err = open(f"{out}/run.err", errors="ignore").read()
    w = re.search(r"Elapsed \(wall clock\) time.*?:\s*([0-9:.]+)", err)
    r = re.search(r"Maximum resident set size \(kbytes\):\s*(\d+)", err)
    if w:
        q = [float(x) for x in w.group(1).split(":")]
        res["wall_s"] = q[-1] + (q[-2]*60 if len(q)>1 else 0) + (q[-3]*3600 if len(q)>2 else 0)
    else: res["wall_s"] = None
    res["rss_mb"] = round(int(r.group(1))/1024, 1) if r else None
    res["squashfuse_warn"] = "squashfuse" in err

    tgt = spec.get("consistency",{}).get("docker_file","")
    tgt = subst(tgt, vars_, out) if tgt else ""
    res["sha256"] = sha256(tgt) if tgt and os.path.exists(tgt) else ""
    res["target"] = os.path.basename(tgt)

    shutil.rmtree(sbx, ignore_errors=True)   # reclaim quota between replicates
    return res

if __name__ == "__main__":
    r = run(sys.argv[1], int(sys.argv[2]))
    print(json.dumps(r))
    with open(f"{BOX}/logs/hpc_runs.jsonl","a") as f: f.write(json.dumps(r)+"\n")
