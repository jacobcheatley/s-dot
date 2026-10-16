# s-dot.plugin.zsh
# Python-str-style text manipulation functions for interactive shell pipelines.
# All functions prefixed `s.` to avoid collisions with coreutils/zsh builtins.
# Default: stream stdin per-line. Pass `-w` / `--whole` to operate on entire stdin as one string.

# Internal helper: shells out to a python one-liner with args after `--`.
# First arg is the python source. Optional `--` separator, then argv tokens
# (which appear as sys.argv[1:] inside the python process).
_s_py () {
    local src="$1"; shift
    [[ "$1" == "--" ]] && shift
    uv run --python 3.13 python -c "$src" "$@"
}

s.lower () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.lower" >&2; return 2; fi
    tr '[:upper:]' '[:lower:]'
}

s.upper () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.upper" >&2; return 2; fi
    tr '[:lower:]' '[:upper:]'
}

s.swapcase () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.swapcase" >&2; return 2; fi
    # ASCII-only. For unicode swapcase pipe through python instead.
    tr 'A-Za-z' 'a-zA-Z'
}

s.capitalize () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.capitalize" >&2; return 2; fi
    if (( whole )); then
        _s_py 'import sys; s=sys.stdin.read(); sys.stdout.write(s.capitalize())'
    else
        _s_py 'import sys
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(line.rstrip("\n").capitalize() + nl)
'
    fi
}

s.title () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.title" >&2; return 2; fi
    if (( whole )); then
        _s_py 'import sys; s=sys.stdin.read(); sys.stdout.write(s.title())'
    else
        _s_py 'import sys
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(line.rstrip("\n").title() + nl)
'
    fi
}

s.strip () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.strip [chars]" >&2; return 2; fi
    local chars="$1"
    if (( whole )); then
        _s_py 'import sys
chars = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] else None
sys.stdout.write(sys.stdin.read().strip(chars))
' -- "$chars"
    else
        _s_py 'import sys
chars = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] else None
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(line.rstrip("\n").strip(chars) + nl)
' -- "$chars"
    fi
}

s.lstrip () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.lstrip [chars]" >&2; return 2; fi
    local chars="$1"
    if (( whole )); then
        _s_py 'import sys
chars = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] else None
sys.stdout.write(sys.stdin.read().lstrip(chars))
' -- "$chars"
    else
        _s_py 'import sys
chars = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] else None
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(line.rstrip("\n").lstrip(chars) + nl)
' -- "$chars"
    fi
}

s.rstrip () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.rstrip [chars]" >&2; return 2; fi
    local chars="$1"
    if (( whole )); then
        _s_py 'import sys
chars = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] else None
sys.stdout.write(sys.stdin.read().rstrip(chars))
' -- "$chars"
    else
        _s_py 'import sys
chars = sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] else None
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(line.rstrip("\n").rstrip(chars) + nl)
' -- "$chars"
    fi
}

s.ljust () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.ljust N [fill]" >&2; return 2; fi
    local n="$1" fill="${2:- }"
    if (( whole )); then
        _s_py 'import sys
n=int(sys.argv[1]); f=sys.argv[2]
sys.stdout.write(sys.stdin.read().ljust(n, f))
' -- "$n" "$fill"
    else
        _s_py 'import sys
n=int(sys.argv[1]); f=sys.argv[2]
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(line.rstrip("\n").ljust(n, f) + nl)
' -- "$n" "$fill"
    fi
}

s.rjust () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.rjust N [fill]" >&2; return 2; fi
    local n="$1" fill="${2:- }"
    if (( whole )); then
        _s_py 'import sys
n=int(sys.argv[1]); f=sys.argv[2]
sys.stdout.write(sys.stdin.read().rjust(n, f))
' -- "$n" "$fill"
    else
        _s_py 'import sys
n=int(sys.argv[1]); f=sys.argv[2]
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(line.rstrip("\n").rjust(n, f) + nl)
' -- "$n" "$fill"
    fi
}

s.center () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.center N [fill]" >&2; return 2; fi
    local n="$1" fill="${2:- }"
    if (( whole )); then
        _s_py 'import sys
n=int(sys.argv[1]); f=sys.argv[2]
sys.stdout.write(sys.stdin.read().center(n, f))
' -- "$n" "$fill"
    else
        _s_py 'import sys
n=int(sys.argv[1]); f=sys.argv[2]
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(line.rstrip("\n").center(n, f) + nl)
' -- "$n" "$fill"
    fi
}

s.zfill () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.zfill N" >&2; return 2; fi
    local n="$1"
    if (( whole )); then
        _s_py 'import sys
n=int(sys.argv[1])
sys.stdout.write(sys.stdin.read().zfill(n))
' -- "$n"
    else
        _s_py 'import sys
n=int(sys.argv[1])
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(line.rstrip("\n").zfill(n) + nl)
' -- "$n"
    fi
}

s.replace () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.replace OLD NEW" >&2; return 2; fi
    if [[ $# -lt 2 ]]; then echo "s.replace: needs OLD and NEW args" >&2; return 2; fi
    local old="$1" new="$2"
    if (( whole )); then
        _s_py 'import sys
o, n = sys.argv[1], sys.argv[2]
sys.stdout.write(sys.stdin.read().replace(o, n))
' -- "$old" "$new"
    else
        _s_py 'import sys
o, n = sys.argv[1], sys.argv[2]
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(line.rstrip("\n").replace(o, n) + nl)
' -- "$old" "$new"
    fi
}

s.contains () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.contains SUB" >&2; return 2; fi
    local sub="$1"
    if (( whole )); then
        _s_py 'import sys
sub = sys.argv[1]
data = sys.stdin.read()
if sub in data:
    sys.stdout.write(data)
' -- "$sub"
    else
        grep -F -- "$sub" || true
    fi
}

s.startswith () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.startswith PFX" >&2; return 2; fi
    local pfx="$1"
    if (( whole )); then
        _s_py 'import sys
pfx = sys.argv[1]
data = sys.stdin.read()
if data.startswith(pfx):
    sys.stdout.write(data)
' -- "$pfx"
    else
        awk -v p="$pfx" 'index($0,p)==1'
    fi
}

s.endswith () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.endswith SFX" >&2; return 2; fi
    local sfx="$1"
    if (( whole )); then
        _s_py 'import sys
sfx = sys.argv[1]
data = sys.stdin.read()
needle_target = data[:-1] if data.endswith("\n") else data
if needle_target.endswith(sfx):
    sys.stdout.write(data)
' -- "$sfx"
    else
        awk -v s="$sfx" 'length($0) >= length(s) && substr($0, length($0)-length(s)+1) == s'
    fi
}

s.count () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.count SUB" >&2; return 2; fi
    local sub="$1"
    if (( whole )); then
        _s_py 'import sys; print(sys.stdin.read().count(sys.argv[1]))' -- "$sub"
    else
        _s_py 'import sys
sub = sys.argv[1]
for line in sys.stdin:
    print(line.rstrip("\n").count(sub))
' -- "$sub"
    fi
}

s.split () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.split [SEP]" >&2; return 2; fi
    local sep="$1"
    if [[ -z "$sep" ]] && [[ $# -eq 0 ]]; then
        tr -s '[:space:]' '\n' | sed '/^$/d'
    elif [[ -z "$sep" ]]; then
        fold -w1
    else
        _s_py 'import sys
sep = sys.argv[1]
data = sys.stdin.read()
if data.endswith("\n"):
    data = data[:-1]
print("\n".join(data.split(sep)))
' -- "$sep"
    fi
}

s.join () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.join [SEP]" >&2; return 2; fi
    local sep="$1"
    _s_py 'import sys
sep = sys.argv[1] if len(sys.argv) > 1 else ""
lines = sys.stdin.read().splitlines()
sys.stdout.write(sep.join(lines))
' -- "$sep"
}

s.chars () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.chars" >&2; return 2; fi
    fold -w1 | sed '/^$/d'
}

s.words () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.words" >&2; return 2; fi
    tr -s '[:space:]' '\n' | sed '/^$/d'
}

s.lines () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.lines" >&2; return 2; fi
    cat -
}

s.reverse () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.reverse" >&2; return 2; fi
    if (( whole )); then
        _s_py 'import sys; sys.stdout.write(sys.stdin.read()[::-1])'
    else
        rev
    fi
}

s.slice () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.slice START [END]" >&2; return 2; fi
    if [[ $# -lt 1 ]]; then echo "s.slice: need START" >&2; return 2; fi
    local start="$1" end="${2:-}"
    if (( whole )); then
        _s_py 'import sys
start = int(sys.argv[1])
end = int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2] != "" else None
sys.stdout.write(sys.stdin.read()[start:end])
' -- "$start" "$end"
    else
        _s_py 'import sys
start = int(sys.argv[1])
end = int(sys.argv[2]) if len(sys.argv) > 2 and sys.argv[2] != "" else None
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(line.rstrip("\n")[start:end] + nl)
' -- "$start" "$end"
    fi
}

s.len () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.len" >&2; return 2; fi
    if (( whole )); then
        _s_py 'import sys; print(len(sys.stdin.read()))'
    else
        awk '{ print length }'
    fi
}

s.repeat () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.repeat N" >&2; return 2; fi
    local n="$1"
    if (( whole )); then
        _s_py 'import sys; n=int(sys.argv[1]); sys.stdout.write(sys.stdin.read()*n)' -- "$n"
    else
        awk -v n="$n" '{ out=""; for (i=0;i<n;i++) out = out $0; print out }'
    fi
}

# ============================================================
# === v2 additions ===
# ============================================================

# --- Line ops ---

s.sort () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.sort" >&2; return 2; fi
    LC_ALL=C sort
}

s.rsort () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.rsort" >&2; return 2; fi
    LC_ALL=C sort -r
}

s.uniq () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.uniq" >&2; return 2; fi
    awk '!seen[$0]++'
}

s.shuffle () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.shuffle" >&2; return 2; fi
    shuf
}

s.enumerate () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.enumerate [START] [SEP]" >&2; return 2; fi
    local tab=$'\t'
    local start="${1:-0}" sep="${2:-$tab}"
    awk -v s="$start" -v sep="$sep" '{printf "%d%s%s\n", NR-1+s, sep, $0}'
}

s.head () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.head N" >&2; return 2; fi
    head -n "$1"
}

s.tail () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.tail N" >&2; return 2; fi
    tail -n "$1"
}

# --- Python str completions ---

s.find () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.find SUB" >&2; return 2; fi
    local sub="$1"
    if (( whole )); then
        _s_py 'import sys
sub = sys.argv[1]
print(sys.stdin.read().find(sub))
' -- "$sub"
    else
        _s_py 'import sys
sub = sys.argv[1]
for line in sys.stdin:
    print(line.rstrip("\n").find(sub))
' -- "$sub"
    fi
}

s.rfind () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.rfind SUB" >&2; return 2; fi
    local sub="$1"
    if (( whole )); then
        _s_py 'import sys
sub = sys.argv[1]
print(sys.stdin.read().rfind(sub))
' -- "$sub"
    else
        _s_py 'import sys
sub = sys.argv[1]
for line in sys.stdin:
    print(line.rstrip("\n").rfind(sub))
' -- "$sub"
    fi
}

s.index () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.index SUB" >&2; return 2; fi
    local sub="$1"
    if (( whole )); then
        _s_py 'import sys
sub = sys.argv[1]
try:
    print(sys.stdin.read().index(sub))
except ValueError:
    sys.exit(1)
' -- "$sub"
    else
        _s_py 'import sys
sub = sys.argv[1]
rc = 0
for line in sys.stdin:
    try:
        print(line.rstrip("\n").index(sub))
    except ValueError:
        rc = 1
sys.exit(rc)
' -- "$sub"
    fi
}

s.rindex () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.rindex SUB" >&2; return 2; fi
    local sub="$1"
    if (( whole )); then
        _s_py 'import sys
sub = sys.argv[1]
try:
    print(sys.stdin.read().rindex(sub))
except ValueError:
    sys.exit(1)
' -- "$sub"
    else
        _s_py 'import sys
sub = sys.argv[1]
rc = 0
for line in sys.stdin:
    try:
        print(line.rstrip("\n").rindex(sub))
    except ValueError:
        rc = 1
sys.exit(rc)
' -- "$sub"
    fi
}

s.partition () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.partition SEP" >&2; return 2; fi
    local sep="$1"
    if (( whole )); then
        _s_py 'import sys
sep = sys.argv[1]
head, s, tail = sys.stdin.read().partition(sep)
sys.stdout.write(head + "\n" + s + "\n" + tail + "\n")
' -- "$sep"
    else
        _s_py 'import sys
sep = sys.argv[1]
for line in sys.stdin:
    head, s, tail = line.rstrip("\n").partition(sep)
    sys.stdout.write(head + "\n" + s + "\n" + tail + "\n")
' -- "$sep"
    fi
}

s.rpartition () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.rpartition SEP" >&2; return 2; fi
    local sep="$1"
    if (( whole )); then
        _s_py 'import sys
sep = sys.argv[1]
head, s, tail = sys.stdin.read().rpartition(sep)
sys.stdout.write(head + "\n" + s + "\n" + tail + "\n")
' -- "$sep"
    else
        _s_py 'import sys
sep = sys.argv[1]
for line in sys.stdin:
    head, s, tail = line.rstrip("\n").rpartition(sep)
    sys.stdout.write(head + "\n" + s + "\n" + tail + "\n")
' -- "$sep"
    fi
}

s.removeprefix () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.removeprefix PFX" >&2; return 2; fi
    local pfx="$1"
    if (( whole )); then
        _s_py 'import sys
pfx = sys.argv[1]
sys.stdout.write(sys.stdin.read().removeprefix(pfx))
' -- "$pfx"
    else
        _s_py 'import sys
pfx = sys.argv[1]
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(line.rstrip("\n").removeprefix(pfx) + nl)
' -- "$pfx"
    fi
}

s.removesuffix () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.removesuffix SFX" >&2; return 2; fi
    local sfx="$1"
    if (( whole )); then
        _s_py 'import sys
sfx = sys.argv[1]
sys.stdout.write(sys.stdin.read().removesuffix(sfx))
' -- "$sfx"
    else
        _s_py 'import sys
sfx = sys.argv[1]
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(line.rstrip("\n").removesuffix(sfx) + nl)
' -- "$sfx"
    fi
}

s.expandtabs () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.expandtabs [N]" >&2; return 2; fi
    local n="${1:-8}"
    if (( whole )); then
        _s_py 'import sys
n = int(sys.argv[1])
sys.stdout.write(sys.stdin.read().expandtabs(n))
' -- "$n"
    else
        _s_py 'import sys
n = int(sys.argv[1])
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(line.rstrip("\n").expandtabs(n) + nl)
' -- "$n"
    fi
}

s.translate () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.translate FROM TO" >&2; return 2; fi
    if [[ $# -lt 2 ]]; then echo "s.translate: needs FROM and TO args" >&2; return 2; fi
    local from="$1" to="$2"
    if (( whole )); then
        _s_py 'import sys
f, t = sys.argv[1], sys.argv[2]
sys.stdout.write(sys.stdin.read().translate(str.maketrans(f, t)))
' -- "$from" "$to"
    else
        _s_py 'import sys
f, t = sys.argv[1], sys.argv[2]
tbl = str.maketrans(f, t)
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(line.rstrip("\n").translate(tbl) + nl)
' -- "$from" "$to"
    fi
}

# --- Predicate filters ---

s.isupper () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.isupper" >&2; return 2; fi
    if (( whole )); then
        _s_py 'import sys
data = sys.stdin.read()
check = data[:-1] if data.endswith("\n") else data
if check.isupper():
    sys.stdout.write(data)
'
    else
        _s_py 'import sys
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    if line.rstrip("\n").isupper():
        sys.stdout.write(line.rstrip("\n") + nl)
'
    fi
}

s.islower () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.islower" >&2; return 2; fi
    if (( whole )); then
        _s_py 'import sys
data = sys.stdin.read()
check = data[:-1] if data.endswith("\n") else data
if check.islower():
    sys.stdout.write(data)
'
    else
        _s_py 'import sys
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    if line.rstrip("\n").islower():
        sys.stdout.write(line.rstrip("\n") + nl)
'
    fi
}

s.isdigit () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.isdigit" >&2; return 2; fi
    if (( whole )); then
        _s_py 'import sys
data = sys.stdin.read()
check = data[:-1] if data.endswith("\n") else data
if check.isdigit():
    sys.stdout.write(data)
'
    else
        _s_py 'import sys
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    if line.rstrip("\n").isdigit():
        sys.stdout.write(line.rstrip("\n") + nl)
'
    fi
}

s.isalpha () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.isalpha" >&2; return 2; fi
    if (( whole )); then
        _s_py 'import sys
data = sys.stdin.read()
check = data[:-1] if data.endswith("\n") else data
if check.isalpha():
    sys.stdout.write(data)
'
    else
        _s_py 'import sys
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    if line.rstrip("\n").isalpha():
        sys.stdout.write(line.rstrip("\n") + nl)
'
    fi
}

s.isalnum () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.isalnum" >&2; return 2; fi
    if (( whole )); then
        _s_py 'import sys
data = sys.stdin.read()
check = data[:-1] if data.endswith("\n") else data
if check.isalnum():
    sys.stdout.write(data)
'
    else
        _s_py 'import sys
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    if line.rstrip("\n").isalnum():
        sys.stdout.write(line.rstrip("\n") + nl)
'
    fi
}

s.isspace () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.isspace" >&2; return 2; fi
    if (( whole )); then
        _s_py 'import sys
data = sys.stdin.read()
check = data[:-1] if data.endswith("\n") else data
if check.isspace():
    sys.stdout.write(data)
'
    else
        _s_py 'import sys
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    if line.rstrip("\n").isspace():
        sys.stdout.write(line.rstrip("\n") + nl)
'
    fi
}

s.isascii () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.isascii" >&2; return 2; fi
    if (( whole )); then
        _s_py 'import sys
data = sys.stdin.read()
check = data[:-1] if data.endswith("\n") else data
if check.isascii():
    sys.stdout.write(data)
'
    else
        _s_py 'import sys
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    if line.rstrip("\n").isascii():
        sys.stdout.write(line.rstrip("\n") + nl)
'
    fi
}

# --- Format ---

s.format () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.format TEMPLATE" >&2; return 2; fi
    if [[ $# -lt 1 ]]; then echo "s.format: needs TEMPLATE arg" >&2; return 2; fi
    local tmpl="$1"
    if (( whole )); then
        _s_py 'import sys
tmpl = sys.argv[1]
sys.stdout.write(tmpl.format(sys.stdin.read()))
' -- "$tmpl"
    else
        _s_py 'import sys
tmpl = sys.argv[1]
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(tmpl.format(line.rstrip("\n")) + nl)
' -- "$tmpl"
    fi
}

# --- Regex ---

s.re_replace () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.re_replace PATTERN REPL" >&2; return 2; fi
    if [[ $# -lt 2 ]]; then echo "s.re_replace: needs PATTERN and REPL args" >&2; return 2; fi
    local pat="$1" repl="$2"
    if (( whole )); then
        _s_py 'import sys, re
pat, repl = sys.argv[1], sys.argv[2]
sys.stdout.write(re.sub(pat, repl, sys.stdin.read()))
' -- "$pat" "$repl"
    else
        _s_py 'import sys, re
pat, repl = sys.argv[1], sys.argv[2]
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(re.sub(pat, repl, line.rstrip("\n")) + nl)
' -- "$pat" "$repl"
    fi
}

s.re_match () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.re_match PATTERN" >&2; return 2; fi
    local pat="$1"
    if (( whole )); then
        _s_py 'import sys, re
pat = sys.argv[1]
data = sys.stdin.read()
if re.search(pat, data):
    sys.stdout.write(data)
' -- "$pat"
    else
        _s_py 'import sys, re
pat = sys.argv[1]
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    s = line.rstrip("\n")
    if re.search(pat, s):
        sys.stdout.write(s + nl)
' -- "$pat"
    fi
}

s.re_find () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.re_find PATTERN" >&2; return 2; fi
    local pat="$1"
    if (( whole )); then
        _s_py 'import sys, re
pat = sys.argv[1]
data = sys.stdin.read()
r = re.compile(pat)
for m in r.finditer(data):
    if r.groups == 1:
        print(m.group(1))
    else:
        print(m.group(0))
' -- "$pat"
    else
        _s_py 'import sys, re
pat = sys.argv[1]
r = re.compile(pat)
for line in sys.stdin:
    s = line.rstrip("\n")
    for m in r.finditer(s):
        if r.groups == 1:
            print(m.group(1))
        else:
            print(m.group(0))
' -- "$pat"
    fi
}

s.re_split () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.re_split PATTERN" >&2; return 2; fi
    local pat="$1"
    if (( whole )); then
        _s_py 'import sys, re
pat = sys.argv[1]
data = sys.stdin.read()
if data.endswith("\n"):
    data = data[:-1]
print("\n".join(re.split(pat, data)))
' -- "$pat"
    else
        _s_py 'import sys, re
pat = sys.argv[1]
for line in sys.stdin:
    s = line.rstrip("\n")
    print("\n".join(re.split(pat, s)))
' -- "$pat"
    fi
}

# --- Text shaping ---

s.wrap () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.wrap N" >&2; return 2; fi
    local n="$1"
    if (( whole )); then
        _s_py 'import sys, textwrap
n = int(sys.argv[1])
sys.stdout.write(textwrap.fill(sys.stdin.read(), width=n) + "\n")
' -- "$n"
    else
        _s_py 'import sys, textwrap
n = int(sys.argv[1])
for line in sys.stdin:
    print(textwrap.fill(line.rstrip("\n"), width=n))
' -- "$n"
    fi
}

s.truncate () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.truncate N [SUFFIX]" >&2; return 2; fi
    local n="$1" suffix="${2:-…}"
    # Note: if N < len(SUFFIX), we emit suffix[:N] to honor "final length <= N"
    if (( whole )); then
        _s_py 'import sys
n = int(sys.argv[1]); suf = sys.argv[2]
data = sys.stdin.read()
if len(data) <= n:
    sys.stdout.write(data)
else:
    cut = n - len(suf)
    if cut < 0:
        sys.stdout.write(suf[:n])
    else:
        sys.stdout.write(data[:cut] + suf)
' -- "$n" "$suffix"
    else
        _s_py 'import sys
n = int(sys.argv[1]); suf = sys.argv[2]
for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    s = line.rstrip("\n")
    if len(s) <= n:
        sys.stdout.write(s + nl)
    else:
        cut = n - len(suf)
        if cut < 0:
            sys.stdout.write(suf[:n] + nl)
        else:
            sys.stdout.write(s[:cut] + suf + nl)
' -- "$n" "$suffix"
    fi
}

s.prefix () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.prefix STR" >&2; return 2; fi
    local p="$1"
    awk -v p="$p" '{print p $0}'
}

s.suffix () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.suffix STR" >&2; return 2; fi
    local s="$1"
    awk -v s="$s" '{print $0 s}'
}

s.indent () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.indent N [CHAR]" >&2; return 2; fi
    local n="$1" char="${2:- }"
    _s_py 'import sys, textwrap
n = int(sys.argv[1]); ch = sys.argv[2]; whole = int(sys.argv[3])
prefix = ch * n
data = sys.stdin.read()
if whole:
    out = textwrap.indent(data, prefix, predicate=lambda _: True)
else:
    out = textwrap.indent(data, prefix)
sys.stdout.write(out)
' -- "$n" "$char" "$whole"
}

s.dedent () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.dedent" >&2; return 2; fi
    _s_py 'import sys, textwrap
sys.stdout.write(textwrap.dedent(sys.stdin.read()))
'
}

# --- Case style converters ---

# Shared Python source for the 5 case-conversion modes. Tokenizes each input
# line on separator chars + camel-boundaries, then re-assembles per the mode
# passed as sys.argv[1]. `-w` is accepted for uniformity but is a no-op since
# these operate on individual identifiers.
_s_caseconv_py='import sys, re
def tokens(s):
    out = []
    for chunk in re.split(r"[_\-\s]+", s):
        chunk = re.sub(r"(?<=[a-z0-9])(?=[A-Z])", " ", chunk)
        chunk = re.sub(r"(?<=[A-Z])(?=[A-Z][a-z])", " ", chunk)
        for tok in chunk.split(" "):
            if tok:
                out.append(tok.lower())
    return out

mode = sys.argv[1]
def convert(s):
    ts = tokens(s)
    if not ts: return ""
    if mode == "snake":  return "_".join(ts)
    if mode == "kebab":  return "-".join(ts)
    if mode == "const":  return "_".join(ts).upper()
    if mode == "camel":  return ts[0] + "".join(t.capitalize() for t in ts[1:])
    if mode == "pascal": return "".join(t.capitalize() for t in ts)
    return s

for line in sys.stdin:
    nl = "\n" if line.endswith("\n") else ""
    sys.stdout.write(convert(line.rstrip("\n")) + nl)
'

s.snake () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.snake" >&2; return 2; fi
    _s_py "$_s_caseconv_py" -- snake
}

s.kebab () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.kebab" >&2; return 2; fi
    _s_py "$_s_caseconv_py" -- kebab
}

s.camel () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.camel" >&2; return 2; fi
    _s_py "$_s_caseconv_py" -- camel
}

s.pascal () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.pascal" >&2; return 2; fi
    _s_py "$_s_caseconv_py" -- pascal
}

s.const () {
    local whole=0
    [[ "$1" == "-w" || "$1" == "--whole" ]] && { whole=1; shift; }
    if [[ -t 0 ]]; then echo "Usage: ... | s.const" >&2; return 2; fi
    _s_py "$_s_caseconv_py" -- const
}
