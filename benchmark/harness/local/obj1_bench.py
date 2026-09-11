#!/usr/bin/env python3
"""Obj1 docker-vs-native benchmark harness.

Measures, per tool, for both NATIVE and DOCKER:
  - SETUP  (install): wall-time (+ native install RAM where applicable)
  - EXEC   (run on pcancer): wall-time + peak RSS (MaxRSS)
  - CONSISTENCY: native-vs-docker output (SHA for deterministic, Pearson r for MCMC)

MEMORY METHOD : peak RSS via GNU `/usr/bin/time -v`
(Maximum resident set size), the SAME instrument on both sides. For docker the host `time` binary
is bind-mounted read-only into the UNMODIFIED image (one identical instrument across all tools;
no image rebuild). RSS excludes reclaimable page cache, so bind-mount cache asymmetry does not bias
the comparison. cgroup memory.peak and `docker stats` are NOT used.

Usage:
  python3 obj1_bench.py list
  python3 obj1_bench.py run-native  <tool> [--rep N]
  python3 obj1_bench.py run-docker  <tool> [--rep N]
  python3 obj1_bench.py setup-docker <tool> [--rep N]     # times `docker pull` of the pristine image
  python3 obj1_bench.py consistency <tool>
  python3 obj1_bench.py exec <tool> [--rep N]             # run-native + run-docker + consistency
"""
import argparse, csv, json, os, re, subprocess, time
from datetime import datetime, timezone
from pathlib import Path

HARNESS = Path(__file__).resolve().parent
REAL = HARNESS.parent
LOGS = REAL / "logs"; RUNS = REAL / "runs"
HOST_TIME = "/usr/bin/time"
MAXRSS_RE = re.compile(r"Maximum resident set size \(kbytes\):\s*(\d+)")
SETUP_CSV = LOGS / "setup_log.csv"
RUNTIME_CSV = LOGS / "runtime_log.csv"
CONS_TSV = LOGS / "consistency_report.tsv"
MANIFEST_TSV = LOGS / "run_manifest.tsv"   # structured per-run audit record (reproducibility)
CSV_COLS = ["timestamp", "tool", "mode", "phase", "replicate", "wall_s", "max_rss_mb",
            "exit_code", "notes"]
MANIFEST_COLS = ["timestamp", "tool", "mode", "phase", "replicate", "image", "digest",
                 "exit_code", "wall_s", "max_rss_mb", "full_command"]


def _now():
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def load_registry():
    return json.loads((HARNESS / "registry.json").read_text())["tools"]


def resolve(s, ctx):
    if not isinstance(s, str):
        return s
    for _ in range(6):
        ns = s.format(**ctx)
        if ns == s:
            return ns
        s = ns
    return s


def _maxrss_mb(stderr_text):
    m = MAXRSS_RE.search(stderr_text or "")
    return round(int(m.group(1)) / 1024.0, 1) if m else None


def _append_csv(path, row):
    path.parent.mkdir(parents=True, exist_ok=True)
    new = not path.exists()
    with path.open("a", newline="") as f:
        w = csv.DictWriter(f, fieldnames=CSV_COLS, extrasaction="ignore")
        if new:
            w.writeheader()
        w.writerow(row)


def _image_digest(image):
    """Resolve the immutable repo digest (sha256) of a local docker image tag.
    Returns 'repo@sha256:...' if available, else the image Id, else ''."""
    try:
        out = subprocess.run(["docker", "inspect", "--format",
                              "{{if .RepoDigests}}{{index .RepoDigests 0}}{{else}}{{.Id}}{{end}}",
                              image], capture_output=True, text=True)
        return (out.stdout or "").strip() if out.returncode == 0 else ""
    except Exception:
        return ""


def _append_manifest(row):
    """One structured audit line per run: image@digest, exit, wall, rss, full command."""
    MANIFEST_TSV.parent.mkdir(parents=True, exist_ok=True)
    new = not MANIFEST_TSV.exists()
    with MANIFEST_TSV.open("a") as f:
        if new:
            f.write("\t".join(MANIFEST_COLS) + "\n")
        f.write("\t".join(str(row.get(c, "")).replace("\t", " ").replace("\n", " ")
                          for c in MANIFEST_COLS) + "\n")


def _ctx_for(tool, spec):
    nat = RUNS / tool / "native"; doc = RUNS / tool / "docker"
    nat.mkdir(parents=True, exist_ok=True); doc.mkdir(parents=True, exist_ok=True)
    ctx = {"NATIVE_OUT": str(nat), "DOCKER_OUT": str(doc),
           "NATIVE_ENV": str(REAL / "native_envs")}
    for k, v in (spec.get("vars") or {}).items():
        ctx[k] = v
    # resolve vars that reference other vars
    for _ in range(6):
        ctx = {k: (resolve(v, ctx) if isinstance(v, str) else v) for k, v in ctx.items()}
    return ctx


def run_native(tool, spec, rep):
    ctx = _ctx_for(tool, spec)
    cmd = resolve(spec["exec"]["native"], ctx)
    log = RUNS / tool / "native" / f"exec_rep{rep}.log"
    t0 = time.monotonic()
    p = subprocess.run([HOST_TIME, "-v", "bash", "-lc", cmd],
                       capture_output=True, text=True)
    wall = round(time.monotonic() - t0, 2)
    log.write_text((p.stdout or "") + "\n----STDERR----\n" + (p.stderr or ""))
    rss = _maxrss_mb(p.stderr)
    _append_csv(RUNTIME_CSV, {"timestamp": _now(), "tool": tool, "mode": "native",
                              "phase": "exec", "replicate": rep, "wall_s": wall,
                              "max_rss_mb": rss, "exit_code": p.returncode, "notes": ""})
    _append_manifest({"timestamp": _now(), "tool": tool, "mode": "native", "phase": "exec",
                      "replicate": rep, "image": f"native:{tool}", "digest": "",
                      "exit_code": p.returncode, "wall_s": wall, "max_rss_mb": rss,
                      "full_command": cmd})
    print(f"[native exec] {tool} rep{rep}: wall={wall}s MaxRSS={rss}MiB exit={p.returncode}")
    return p.returncode


def run_docker(tool, spec, rep):
    ctx = _ctx_for(tool, spec)
    d = spec["exec"]["docker"]
    image = resolve(d["image"], ctx)
    mounts = [resolve(m, ctx) for m in d["mounts"]]
    inner = resolve(d["cmd"], ctx)
    # Prefer the container's own GNU time (/usr/bin/time); fall back to the bind-mounted host
    # time (at /usr/local/bin/htime) for images that lack it. MaxRSS is kernel getrusage either
    # way, so the value is identical. (The host binary can fail on older-glibc images.)
    args = ["docker", "run", "--rm", "-v", f"{HOST_TIME}:/usr/local/bin/htime:ro"]
    for m in mounts:
        args += ["-v", m]
    args += [image, "sh", "-c",
             f'T=/usr/bin/time; [ -x "$T" ] || T=/usr/local/bin/htime; "$T" -v {inner}']
    log = RUNS / tool / "docker" / f"exec_rep{rep}.log"
    digest = _image_digest(image)
    t0 = time.monotonic()
    p = subprocess.run(args, capture_output=True, text=True)
    wall = round(time.monotonic() - t0, 2)
    log.write_text((p.stdout or "") + "\n----STDERR----\n" + (p.stderr or ""))
    rss = _maxrss_mb(p.stderr)
    _append_csv(RUNTIME_CSV, {"timestamp": _now(), "tool": tool, "mode": "docker",
                              "phase": "exec", "replicate": rep, "wall_s": wall,
                              "max_rss_mb": rss, "exit_code": p.returncode,
                              "notes": digest or image})
    _append_manifest({"timestamp": _now(), "tool": tool, "mode": "docker", "phase": "exec",
                      "replicate": rep, "image": image, "digest": digest,
                      "exit_code": p.returncode, "wall_s": wall, "max_rss_mb": rss,
                      "full_command": " ".join(args)})
    print(f"[docker exec] {tool} rep{rep}: wall={wall}s MaxRSS={rss}MiB exit={p.returncode}")
    return p.returncode


def setup_native(tool, spec, rep):
    """Time the CLEAN native install (fresh isolated env, boundary a) under /usr/bin/time."""
    ctx = _ctx_for(tool, spec)
    cmd = resolve(spec.get("setup", {}).get("native"), ctx)
    if not cmd:
        print(f"[setup-native] {tool}: no native install command in registry"); return 1
    log = RUNS / tool / "native" / f"setup_rep{rep}.log"
    t0 = time.monotonic()
    p = subprocess.run([HOST_TIME, "-v", "bash", "-lc", cmd], capture_output=True, text=True)
    wall = round(time.monotonic() - t0, 2)
    log.write_text((p.stdout or "") + "\n----STDERR----\n" + (p.stderr or ""))
    rss = _maxrss_mb(p.stderr)
    _append_csv(SETUP_CSV, {"timestamp": _now(), "tool": tool, "mode": "native",
                            "phase": "setup", "replicate": rep, "wall_s": wall,
                            "max_rss_mb": rss, "exit_code": p.returncode,
                            "notes": "clean native install (boundary a)"})
    _append_manifest({"timestamp": _now(), "tool": tool, "mode": "native", "phase": "setup",
                      "replicate": rep, "image": f"native:{tool}", "digest": "",
                      "exit_code": p.returncode, "wall_s": wall, "max_rss_mb": rss,
                      "full_command": cmd})
    print(f"[setup-native] {tool} rep{rep}: wall={wall}s MaxRSS={rss}MiB exit={p.returncode} (log: {log})")
    return p.returncode


def setup_docker(tool, spec, rep):
    img = spec.get("setup", {}).get("docker_pull")
    if not img:
        print(f"[setup-docker] {tool}: no docker_pull in registry"); return 1
    # Force a TRUE cold pull. STOPPED containers PIN image layers, so rmi can't evict them and the
    # next pull is a cache hit (~4s) instead of a real download. Order: (1) prune stopped containers
    # to release the pins, (2) rmi by IMAGE ID (clears tag + lingering RepoDigest), (3) prune orphaned
    # layers. Only dead containers + this image are touched - other images are untouched.
    subprocess.run(["docker", "container", "prune", "-f"], capture_output=True)  # release layer pins
    repo = img.split("@")[0].rsplit(":", 1)[0]
    ids = set()
    for ref in (img, repo):
        out = subprocess.run(["docker", "images", "-q", ref], capture_output=True, text=True)
        ids.update(out.stdout.split())
    for iid in ids:
        subprocess.run(["docker", "rmi", "-f", iid], capture_output=True)
    subprocess.run(["docker", "image", "prune", "-f"], capture_output=True)  # mop up orphaned layers
    subprocess.run(["docker", "builder", "prune", "-af"], capture_output=True)  # clear BuildKit cache (locally-built images keep layers here -> else pull is a cache hit)
    t0 = time.monotonic()
    p = subprocess.run(["docker", "pull", img], capture_output=True, text=True)
    wall = round(time.monotonic() - t0, 2)
    digest = _image_digest(img)
    _append_csv(SETUP_CSV, {"timestamp": _now(), "tool": tool, "mode": "docker",
                            "phase": "setup", "replicate": rep, "wall_s": wall,
                            "max_rss_mb": "", "exit_code": p.returncode,
                            "notes": f"docker pull {digest or img}"})
    _append_manifest({"timestamp": _now(), "tool": tool, "mode": "docker", "phase": "setup",
                      "replicate": rep, "image": img, "digest": digest,
                      "exit_code": p.returncode, "wall_s": wall, "max_rss_mb": "",
                      "full_command": f"docker pull {img}"})
    print(f"[setup-docker] {tool} rep{rep}: pull wall={wall}s exit={p.returncode} digest={digest or '(none)'}")
    return p.returncode


def _pearson(nf, df, key_col, val_col):
    """Pearson r between native & docker numeric outputs, aligned by key_col (0-based).
    Returns (r, n_common) or (None, 0)."""
    def load(p):
        d = {}
        for line in open(p):
            t = line.split()
            if len(t) > max(key_col, val_col):
                try:
                    d[t[key_col]] = float(t[val_col])
                except ValueError:
                    pass
        return d
    a, b = load(nf), load(df)
    keys = [k for k in a if k in b]
    if len(keys) < 2:
        return None, len(keys)
    xs = [a[k] for k in keys]; ys = [b[k] for k in keys]
    n = len(xs); mx = sum(xs) / n; my = sum(ys) / n
    cov = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    vx = sum((x - mx) ** 2 for x in xs); vy = sum((y - my) ** 2 for y in ys)
    if vx == 0 or vy == 0:
        return (1.0 if xs == ys else 0.0), n
    return cov / ((vx * vy) ** 0.5), n


def consistency(tool, spec):
    ctx = _ctx_for(tool, spec)
    c = spec.get("consistency", {})
    ctype = c.get("type", "sha")
    nf = Path(resolve(c.get("native_file", ""), ctx))
    df = Path(resolve(c.get("docker_file", ""), ctx))
    CONS_TSV.parent.mkdir(parents=True, exist_ok=True)
    new = not CONS_TSV.exists()
    if not nf.is_file() or not df.is_file():
        verdict = f"NO DATA (native={nf.is_file()}, docker={df.is_file()})"
    elif ctype == "pearson":
        r, n = _pearson(nf, df, c.get("key_col", 1), c.get("val_col", 5))
        verdict = f"PEARSON r={r:.6f} (n={n})" if r is not None else f"PEARSON align-failed (n={n})"
    else:  # sha (deterministic tools)
        import hashlib
        hn = hashlib.sha256(nf.read_bytes()).hexdigest()
        hd = hashlib.sha256(df.read_bytes()).hexdigest()
        verdict = "IDENTICAL" if hn == hd else "DIFFERS"
    with CONS_TSV.open("a") as f:
        if new:
            f.write("Tool\tNative_file\tDocker_file\tType\tVerdict\n")
        f.write(f"{tool}\t{nf.name}\t{df.name}\t{ctype}\t{verdict}\n")
    print(f"[consistency] {tool} ({ctype}): {verdict}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", choices=["list", "run-native", "run-docker", "setup-native",
                                    "setup-docker", "consistency", "exec"])
    ap.add_argument("tool", nargs="?")
    ap.add_argument("--rep", type=int, default=1)
    a = ap.parse_args()
    reg = load_registry()
    if a.cmd == "list":
        for t in reg:
            print(t)
        return
    if a.tool not in reg:
        raise SystemExit(f"tool '{a.tool}' not in registry: {list(reg)}")
    spec = reg[a.tool]
    if a.cmd == "setup-native":
        setup_native(a.tool, spec, a.rep)
    elif a.cmd == "run-native":
        run_native(a.tool, spec, a.rep)
    elif a.cmd == "run-docker":
        run_docker(a.tool, spec, a.rep)
    elif a.cmd == "setup-docker":
        setup_docker(a.tool, spec, a.rep)
    elif a.cmd == "consistency":
        consistency(a.tool, spec)
    elif a.cmd == "exec":
        run_native(a.tool, spec, a.rep)
        run_docker(a.tool, spec, a.rep)
        consistency(a.tool, spec)


if __name__ == "__main__":
    main()
