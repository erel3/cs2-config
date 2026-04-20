#!/usr/bin/env python3
"""Validate every cvar/command referenced in *.cfg exists in docs/cvarlist.txt.

Usage: python3 validate.py
Exit 0 = all known, 1 = unknowns found.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).parent
CVARLIST = ROOT / "docs" / "cvarlist.txt"
SKIP_FIRST_TOKENS = {
    "bind", "unbind", "unbindall", "alias", "exec", "echo",
    "toggleconsole", "cancelselect", "switchhandsright",
    "+left", "+right", "+forward", "+back", "+jump", "+duck",
    "+sprint", "+use", "+attack", "+attack2", "+reload",
    "+lookatweapon", "+voicerecord", "+showscores", "+spray_menu",
    "+radialradio", "+radialradio2", "+qsw", "-qsw", "+dropbomb", "-dropbomb",
}

# concommands absent from cvarlist.txt (cvarlist = cvars, not cmdlist). Extend as needed.
KNOWN_CMDS = {
    "buyammo1", "buyammo2", "buymenu", "autobuy", "rebuy", "sellbackall",
    "slot1", "slot2", "slot3", "slot4", "slot5", "slot6", "slot7", "slot8",
    "slot9", "slot10", "slot11", "slot12",
    "drop", "lastinv", "invnext", "invprev",
    "messagemode", "messagemode2", "teammenu", "player_ping", "radio",
    "jpeg", "save", "load", "yaw", "pitch",
    "playerradio", "cs_quit_prompt", "show_loadout_toggle",
    "bot_kick", "bot_add", "bot_add_t", "bot_add_ct", "bot_place", "bot_stop", "bot_crouch",
    "mp_restartgame", "mp_warmup_end", "ent_fire", "god", "noclip",
    "sv_rethrow_last_grenade", "play", "clutch_mode_toggle",
    "toggle", "kill",
}

def load_known():
    if not CVARLIST.exists():
        sys.exit(f"Missing {CVARLIST}. Run `cvarlist` in console and save output there.")
    known = set(KNOWN_CMDS)
    for line in CVARLIST.read_text(errors="ignore").splitlines():
        m = re.match(r'^"([^"]+)"', line)
        if m:
            known.add(m.group(1).lower())
    return known

def tokens(line):
    # strip // comment
    line = re.split(r"//", line, 1)[0].strip()
    if not line:
        return []
    # split top-level on semicolons
    return [c.strip() for c in line.split(";") if c.strip()]

def first_word(cmd):
    # grab first token, handle quoted
    m = re.match(r'^"?([^"\s]+)"?', cmd)
    return m.group(1) if m else ""

def extract_refs(cfg_path):
    """Yield (line_no, name) pairs referenced in cfg."""
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
                                yield (i, w)
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
                                yield (i, w)
                continue
            if head.startswith(("+", "-")):
                yield (i, head.lstrip("+-"))
                continue
            if head in SKIP_FIRST_TOKENS:
                continue
            yield (i, head)

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
    unknowns = []
    for cfg in cfgs:
        for lno, name in extract_refs(cfg):
            key = name.lower()
            if key in known or key in KNOWN_CMDS or name in defined:
                continue
            unknowns.append((cfg.relative_to(ROOT), lno, name))
    if unknowns:
        print("UNKNOWN cvars/commands:")
        for path, lno, name in unknowns:
            print(f"  {path}:{lno}  {name}")
        sys.exit(1)
    print(f"OK — all refs in {len(cfgs)} cfg(s) resolved against cvarlist.txt")

if __name__ == "__main__":
    main()
