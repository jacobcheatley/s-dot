# s.*

Python `str`-style text manipulation for zsh pipelines. Every function is prefixed `s.` so it never collides with coreutils or zsh builtins.

```sh
echo "hello_world fooBar" | s.split | s.pascal   # HelloWorld / FooBar
printf '  x  \n' | s.strip | s.center 5 '*'     # **x**
cat names.txt | s.re_find '(\w+)@' | s.uniq
```

## Why not sed / awk / tr?

You already know what `s.replace`, `s.partition` or `s.slice -3` do, because they behave like the Python `str` methods they are named after. Arguments are literal unless the name says `re_`, so `s.replace '.' '/'` needs no escaping. Slices take negative indexes. Regexes use Python syntax rather than whichever of BRE, ERE or PCRE the local tool speaks.

The cost is speed: functions without a coreutils equivalent start a Python process through `uv` on every call. That's fine at the prompt, but in a hot loop use `sed`/`awk`.

## Usage

Functions read stdin line by line. Pass `-w` / `--whole` as the first argument to operate on all of stdin as one string.

## Requirements

- zsh
- [uv](https://docs.astral.sh/uv/) (Python-backed functions run via `uv run --python 3.13`)

## Install

```sh
git clone git@github.com:jacobcheatley/s-dot.git ~/s-dot
echo 'source ~/s-dot/s-dot.plugin.zsh' >> ~/.zshrc
```

The file is named `*.plugin.zsh`, so plugin managers (oh-my-zsh custom plugins, antidote, zinit) pick it up directly.

## Tab completion

Typing `s.<TAB>` at the start of a command shows every function with a one-line description, grouped by category with coloured headers. Sourcing the plugin sets this up: it adds the repo to `fpath`, autoloads `_s_funcs_dispatcher`, and prepends it to your `completer` zstyle (your existing chain is kept). Source the plugin after any line of your own that sets `completer`, or that line will drop it.

Requires `compinit` to have run, which oh-my-zsh and most frameworks already do. For the nicest menu, add `zstyle ':completion:*' list-grouped yes`.

## Tests

```sh
zsh test.zsh
```

## Functions

`s.lower`, `s.upper`, `s.swapcase`, `s.capitalize`, `s.title`, `s.strip`, `s.lstrip`, `s.rstrip`, `s.ljust`, `s.rjust`, `s.center`, `s.zfill`, `s.replace`, `s.contains`, `s.startswith`, `s.endswith`, `s.count`, `s.split`, `s.join`, `s.chars`, `s.words`, `s.lines`, `s.reverse`, `s.slice`, `s.len`, `s.repeat`, `s.sort`, `s.rsort`, `s.uniq`, `s.shuffle`, `s.enumerate`, `s.head`, `s.tail`, `s.find`, `s.rfind`, `s.index`, `s.rindex`, `s.partition`, `s.rpartition`, `s.removeprefix`, `s.removesuffix`, `s.expandtabs`, `s.translate`, `s.isupper`, `s.islower`, `s.isdigit`, `s.isalpha`, `s.isalnum`, `s.isspace`, `s.isascii`, `s.format`, `s.re_replace`, `s.re_match`, `s.re_find`, `s.re_split`, `s.wrap`, `s.truncate`, `s.prefix`, `s.suffix`, `s.indent`, `s.dedent`, `s.snake`, `s.kebab`, `s.camel`, `s.pascal`, `s.const`
