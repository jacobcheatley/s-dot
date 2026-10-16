# s-dot

Python `str`-style text manipulation for zsh pipelines. Every function is prefixed `s.` so it never collides with coreutils or zsh builtins.

```sh
echo "hello_world fooBar" | s.split | s.pascal   # HelloWorld / FooBar
printf '  x  \n' | s.strip | s.center 5 '*'     # **x**
cat names.txt | s.re_find '(\w+)@' | s.uniq
```

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

## Functions

`s.lower`, `s.upper`, `s.swapcase`, `s.capitalize`, `s.title`, `s.strip`, `s.lstrip`, `s.rstrip`, `s.ljust`, `s.rjust`, `s.center`, `s.zfill`, `s.replace`, `s.contains`, `s.startswith`, `s.endswith`, `s.count`, `s.split`, `s.join`, `s.chars`, `s.words`, `s.lines`, `s.reverse`, `s.slice`, `s.len`, `s.repeat`, `s.sort`, `s.rsort`, `s.uniq`, `s.shuffle`, `s.enumerate`, `s.head`, `s.tail`, `s.find`, `s.rfind`, `s.index`, `s.rindex`, `s.partition`, `s.rpartition`, `s.removeprefix`, `s.removesuffix`, `s.expandtabs`, `s.translate`, `s.isupper`, `s.islower`, `s.isdigit`, `s.isalpha`, `s.isalnum`, `s.isspace`, `s.isascii`, `s.format`, `s.re_replace`, `s.re_match`, `s.re_find`, `s.re_split`, `s.wrap`, `s.truncate`, `s.prefix`, `s.suffix`, `s.indent`, `s.dedent`, `s.snake`, `s.kebab`, `s.camel`, `s.pascal`, `s.const`
