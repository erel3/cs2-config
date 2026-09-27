#!/usr/bin/env python3
"""Validate every cvar/command referenced in *.cfg against the live CS2 build.

Reference = SteamDB's per-build dump (docs/convars.txt, docs/commands.txt).
Refresh (CI does this on every run):
  for f in convars commands; do curl -fsSL -o docs/$f.txt \
    https://raw.githubusercontent.com/SteamDatabase/GameTracking-CS2/master/DumpSource2/$f.txt; done

Fails on: unknown names, `hidden` cvars (legacy aliases the game keeps but
no longer renders, e.g. cl_crosshairsize after the Sep 2026 crosshair rework),
and numeric values outside the cvar's min/max.

Usage: python3 validate.py
Exit 0 = clean, 1 = problems found.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).parent
DUMPS = [ROOT / "docs" / "convars.txt", ROOT / "docs" / "commands.txt"]
SKIP_FIRST_TOKENS = {
    "bind", "unbind", "unbindall", "alias", "exec", "echo",
    "toggleconsole", "cancelselect", "switchhandsright",
    "+left", "+right", "+forward", "+back", "+jump", "+duck",
    "+sprint", "+use", "+attack", "+attack2", "+reload",
    "+lookatweapon", "+voicerecord", "+showscores", "+spray_menu",
    "+radialradio", "+radialradio2", "+qsw", "-qsw", "+dropbomb", "-dropbomb",
}

# real commands the SteamDB dump misses. Extend as needed.
KNOWN_CMDS = {
    "buyammo1", "buyammo2", "drop", "messagemode", "messagemode2",
    "jpeg", "yaw", "pitch", "playerradio",
}

# hidden but deliberately set: pins the resolution crosshair pixel values refer to
ALLOW_HIDDEN = {"cl_crosshair_screen_height"}

def load_known():
    """name -> flags string, e.g. '1 (min: 0, max: 2, clientdll archive per_user)'."""
    known = {c: "" for c in KNOWN_CMDS}
    for dump in DUMPS:
        if not dump.exists():
            sys.exit(f"Missing {dump}. Refresh command is in this file's docstring.")
        for line in dump.read_text(errors="ignore").splitlines():
            if line and not line[0].isspace():
                name, _, rest = line.partition(" ")
                known[name.lower().lstrip("+-")] = rest  # refs are looked up without +/-
    return known

def value_problem(meta, args):
    """Why `args` is not a valid value for a cvar described by `meta`, or None."""
    if re.search(r"\bhidden\b", meta):
        return "hidden/legacy cvar (renamed or no longer rendered)"
    if len(args) != 1:
        return None
    try:
        v = float(args[0].strip('"'))
    except ValueError:
        return None
    lo = re.search(r"min: (-?[\d.]+)", meta)
    hi = re.search(r"max: (-?[\d.]+)", meta)
    if lo and v < float(lo.group(1)) or hi and v > float(hi.group(1)):
        return f"value {args[0]} outside [{lo.group(1) if lo else '-inf'}, {hi.group(1) if hi else 'inf'}]"
    return None

def tokens(line):
    # strip // comment
    line = line.split("//", 1)[0].strip()
    if not line:
        return []
    # split top-level on semicolons
    return [c.strip() for c in line.split(";") if c.strip()]

def first_word(cmd):
    # grab first token, handle quoted
    m = re.match(r'^"?([^"\s]+)"?', cmd)
    return m.group(1) if m else ""

def extract_refs(cfg_path):
    """Yield (line_no, name, args) referenced in cfg; args=None where no value is set."""
    for i, raw in enumerate(cfg_path.read_text().splitlines(), 1):
        for cmd in tokens(raw):
            parts = re.findall(r'"[^"]*"|\S+', cmd)
            if not parts:
                continue
            head = first_word(parts[0])
            # bind "K" "action" → check action chain
            if head in ("bind", "unbind"):
                if len(parts) >= 3:
                    action = parts[2].strip('"')
                    for sub in action.split(";"):
                        sub = sub.strip()
                        if sub:
                            w = first_word(sub)
                            if w and not w.startswith(("+", "-")) and w not in SKIP_FIRST_TOKENS:
                                yield (i, w, None)
                continue
            # alias defines its own name — skip lhs, check rhs chain
            if head == "alias":
                if len(parts) >= 3:
                    rhs = parts[2].strip('"')
                    for sub in rhs.split(";"):
                        sub = sub.strip()
                        if sub:
                            w = first_word(sub)
                            if w and not w.startswith(("+", "-")) and w not in SKIP_FIRST_TOKENS:
                                yield (i, w, None)
                continue
            if head.startswith(("+", "-")):
                yield (i, head.lstrip("+-"), None)
                continue
            if head in SKIP_FIRST_TOKENS:
                continue
            yield (i, head, parts[1:])

VALID_KINDS = {"always", "prompt", "extra"}

def check_manifest():
    """Ensure cfg/manifest.txt and cfg/*.cfg are in sync, kinds are valid,
    and prompt-kind entries have a non-empty prompt text."""
    manifest = ROOT / "cfg" / "manifest.txt"
    if not manifest.exists():
        return ["cfg/manifest.txt missing"]
    listed = set()
    errs = []
    for lno, raw in enumerate(manifest.read_text().splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        parts = [p.strip() for p in line.split("|")]
        if len(parts) < 2:
            errs.append(f"manifest.txt:{lno}  malformed (need filename|kind[|prompt]): {raw}")
            continue
        fname, kind = parts[0], parts[1]
        prompt = parts[2] if len(parts) >= 3 else ""
        if not fname:
            errs.append(f"manifest.txt:{lno}  empty filename")
            continue
        if kind not in VALID_KINDS:
            errs.append(f"manifest.txt:{lno}  invalid kind '{kind}' (allowed: always/prompt/extra)")
        if kind == "prompt" and not prompt:
            errs.append(f"manifest.txt:{lno}  kind=prompt requires prompt text after second '|'")
        listed.add(fname)
    actual = {p.name for p in (ROOT / "cfg").glob("*.cfg") if p.name != "autoexec.cfg"}
    for f in sorted(actual - listed):
        errs.append(f"cfg/{f} exists but is NOT in cfg/manifest.txt — installers will skip it")
    for f in sorted(listed - actual):
        errs.append(f"cfg/manifest.txt lists {f} but file is missing")
    return errs

def main():
    known = load_known()
    # known aliases defined within cfg files — collect first pass
    defined = set()
    cfgs = sorted(ROOT.rglob("*.cfg"))
    for cfg in cfgs:
        for raw in cfg.read_text().splitlines():
            m = re.match(r'\s*alias\s+"?([^\s"]+)"?', raw)
            if m:
                defined.add(m.group(1).lstrip("+-"))
    unknowns, bad = [], []
    for cfg in cfgs:
        for lno, name, args in extract_refs(cfg):
            key = name.lower()
            if name in defined:
                continue
            if key not in known:
                unknowns.append((cfg.relative_to(ROOT), lno, name))
            elif args is not None and key not in ALLOW_HIDDEN:
                why = value_problem(known[key], args)
                if why:
                    bad.append((cfg.relative_to(ROOT), lno, name, why))
    manifest_errs = check_manifest()
    if unknowns or bad or manifest_errs:
        if unknowns:
            print("UNKNOWN cvars/commands:")
            for path, lno, name in unknowns:
                print(f"  {path}:{lno}  {name}")
        if bad:
            print("BAD cvars/values:")
            for path, lno, name, why in bad:
                print(f"  {path}:{lno}  {name}: {why}")
        if manifest_errs:
            print("MANIFEST drift:")
            for e in manifest_errs:
                print(f"  {e}")
        sys.exit(1)
    print(f"OK — all refs in {len(cfgs)} cfg(s) valid against the live-build dump; manifest in sync")

if __name__ == "__main__":
    main()
