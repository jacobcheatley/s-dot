#!/usr/bin/env zsh
# Test harness for s-dot.plugin.zsh. Run: zsh test.zsh

plugin="${0:A:h}/s-dot.plugin.zsh"
source "$plugin"

passed=0
failed=0
failed_cases=()

expect_eq () {
    local desc="$1" expected="$2" actual="$3"
    if [[ "$actual" == "$expected" ]]; then
        passed=$((passed+1))
    else
        failed=$((failed+1))
        failed_cases+=("$desc")
        echo "✗ $desc"
        echo "    expected: $(printf '%q' "$expected")"
        echo "    actual:   $(printf '%q' "$actual")"
    fi
}

# --- canonical pipeline (Task 6 will also verify this) ---
expect_eq "skeleton sanity: harness runs" "ok" "ok"

# --- Case ops ---
expect_eq "s.lower basic"          "abc def"        "$(echo 'ABC DeF' | s.lower)"
expect_eq "s.lower per-line"       $'abc\nxyz'      "$(printf 'ABC\nXYZ\n' | s.lower)"
expect_eq "s.upper basic"          "ABC DEF"        "$(echo 'abc DeF' | s.upper)"
expect_eq "s.swapcase basic"       "aBc dEf"        "$(echo 'AbC DeF' | s.swapcase)"
expect_eq "s.capitalize basic"     "Hello world"    "$(echo 'hELLO wORLD' | s.capitalize)"
expect_eq "s.capitalize per-line"  $'Foo\nBar'      "$(printf 'fOO\nbAR\n' | s.capitalize)"
expect_eq "s.title basic"          "Hello World"    "$(echo 'hello world' | s.title)"
expect_eq "s.title mixed"          "Foo-Bar Baz"    "$(echo 'foo-bar baz' | s.title)"

# --- Trim / pad ---
expect_eq "s.strip whitespace"     "hello"          "$(echo '   hello   ' | s.strip)"
expect_eq "s.strip chars"          "ello worl"      "$(echo 'hhhhello worldhhhh' | s.strip 'hd')"
expect_eq "s.lstrip whitespace"    "hello   "       "$(echo '   hello   ' | s.lstrip)"
expect_eq "s.rstrip whitespace"    "   hello"       "$(echo '   hello   ' | s.rstrip)"
expect_eq "s.ljust pad"            "ab---"          "$(echo 'ab' | s.ljust 5 -)"
expect_eq "s.ljust default fill"   "ab   "          "$(echo 'ab' | s.ljust 5)"
expect_eq "s.ljust too short"      "abcde"          "$(echo 'abcde' | s.ljust 3)"
expect_eq "s.rjust pad"            "---ab"          "$(echo 'ab' | s.rjust 5 -)"
expect_eq "s.center even"          "--ab-"          "$(echo 'ab' | s.center 5 -)"
expect_eq "s.zfill positive"       "0042"           "$(echo '42' | s.zfill 4)"
expect_eq "s.zfill negative"       "-042"           "$(echo '-42' | s.zfill 4)"

# --- Search / replace / count ---
expect_eq "s.replace basic"        "hxllo"          "$(echo 'hello' | s.replace 'el' 'xl')"
expect_eq "s.replace canonical"    "STRING TEXT"    "$(echo 'STRING-TEXT' | s.replace '-' ' ')"
expect_eq "s.replace special chars" "a.b.c"         "$(echo 'a/b/c' | s.replace '/' '.')"
expect_eq "s.contains match"       "foo bar"        "$(printf 'foo bar\nbaz\n' | s.contains 'foo')"
expect_eq "s.contains no match"    ""               "$(printf 'baz\nqux\n' | s.contains 'foo')"
expect_eq "s.startswith match"     "abc def"        "$(printf 'abc def\nxabc\n' | s.startswith 'abc')"
expect_eq "s.endswith match"       "hello world"    "$(printf 'hello world\nworld up\n' | s.endswith 'world')"
expect_eq "s.count basic"          "3"              "$(echo 'banana ban ban' | s.count 'ban')"
expect_eq "s.count zero"           "0"              "$(echo 'hello' | s.count 'z')"
expect_eq "s.contains -w literal *" "a.b"           "$(echo 'a.b' | s.contains -w 'a.b')"
expect_eq "s.contains -w glob char" ""              "$(echo 'a.b' | s.contains -w 'a*')"
expect_eq "s.endswith -w trailing nl" "hello world" "$(echo 'hello world' | s.endswith -w 'world')"

# --- Split / join / slice / shape ---
expect_eq "s.split default ws"     $'foo\nbar\nbaz'         "$(echo 'foo bar baz' | s.split)"
expect_eq "s.split 1-char"         $'a\nb\nc'               "$(echo 'a-b-c' | s.split '-')"
expect_eq "s.split multi-char"     $'aa\nbb\ncc'            "$(echo 'aa::bb::cc' | s.split '::')"
expect_eq "s.split empty sep"      $'a\nb\nc'               "$(echo 'abc' | s.split '')"
expect_eq "s.join no sep"          "abc"                    "$(printf 'a\nb\nc\n' | s.join)"
expect_eq "s.join with sep"        "a-b-c"                  "$(printf 'a\nb\nc\n' | s.join '-')"
expect_eq "s.chars"                $'a\nb\nc'               "$(echo 'abc' | s.chars)"
expect_eq "s.words"                $'foo\nbar'              "$(echo '  foo   bar  ' | s.words)"
expect_eq "s.lines stream"         $'a\nb'                  "$(printf 'a\nb\n' | s.lines)"
expect_eq "s.reverse per-line"     "txet gnirts"            "$(echo 'string text' | s.reverse)"
expect_eq "s.slice positive"       "ell"                    "$(echo 'hello' | s.slice 1 4)"
expect_eq "s.slice open end"       "llo"                    "$(echo 'hello' | s.slice 2)"
expect_eq "s.slice negative"       "llo"                    "$(echo 'hello' | s.slice -3)"
expect_eq "s.len per-line"         "5"                      "$(echo 'hello' | s.len)"
expect_eq "s.repeat 3"             "abcabcabc"              "$(echo 'abc' | s.repeat 3)"

# --- Canonical pipeline from the spec ---
expect_eq "canonical pipeline" "txet gnirts" \
    "$(echo 'STRING-TEXT' | s.replace '-' ' ' | s.lower | s.reverse)"

# --- Whole-mode cases ---
expect_eq "whole-mode reverse incl. newlines" $'CBA\nRTS' \
    "$(printf 'STR\nABC' | s.reverse -w)"
expect_eq "whole-mode count across lines" "2" \
    "$(printf 'foo\nfoo bar\n' | s.count -w 'foo')"
expect_eq "whole-mode contains hit"       $'foo\nbar' \
    "$(printf 'foo\nbar' | s.contains -w $'oo\nba')"

# --- TTY-guard cases (functions must refuse no-stdin invocation) ---
# Note: `[[ -t 0 ]]` only fires when stdin is a real terminal. Closing fd 0
# with `exec 0<&-` makes `[[ -t 0 ]]` false, so the guard misses; and on
# this system `tr` happily returns 0 from closed stdin. To exercise the
# guard properly we allocate a pty via `script -eqfc` so stdin IS a tty.
# Skipped if util-linux `script` isn't available — would otherwise hard-fail
# for the wrong reason.
if command -v script >/dev/null 2>&1; then
    script -eqfc "zsh -c 'source $plugin; s.lower'" /dev/null >/dev/null 2>&1
    expect_eq "s.lower no-stdin exits non-zero" "0" "$(( $? != 0 ? 0 : 1 ))"
else
    echo "skipped: TTY-guard test (util-linux script not found)"
fi

# --- v2: Line ops ---
expect_eq "s.sort basic"           $'apple\nbanana\ncherry'  "$(printf 'banana\napple\ncherry\n' | s.sort)"
expect_eq "s.rsort basic"          $'cherry\nbanana\napple'  "$(printf 'banana\napple\ncherry\n' | s.rsort)"
expect_eq "s.uniq preserves order" $'b\na\nc'                "$(printf 'b\na\nb\nc\na\n' | s.uniq)"
expect_eq "s.uniq nothing to dedup" $'a\nb\nc'               "$(printf 'a\nb\nc\n' | s.uniq)"
expect_eq "s.shuffle len"          "3"                       "$(printf 'a\nb\nc\n' | s.shuffle | wc -l | tr -d ' ')"
expect_eq "s.enumerate default"    $'0\ta\n1\tb\n2\tc'       "$(printf 'a\nb\nc\n' | s.enumerate)"
expect_eq "s.enumerate start=1"    $'1\ta\n2\tb'             "$(printf 'a\nb\n' | s.enumerate 1)"
expect_eq "s.enumerate custom sep" $'0. a\n1. b'             "$(printf 'a\nb\n' | s.enumerate 0 '. ')"
expect_eq "s.head 2"               $'a\nb'                   "$(printf 'a\nb\nc\nd\n' | s.head 2)"
expect_eq "s.tail 2"               $'c\nd'                   "$(printf 'a\nb\nc\nd\n' | s.tail 2)"

# --- v2: str completions ---
expect_eq "s.find hit"              "6"               "$(echo 'hello world' | s.find 'world')"
expect_eq "s.find miss"             "-1"              "$(echo 'hello' | s.find 'z')"
expect_eq "s.rfind"                 "7"               "$(echo 'hello world' | s.rfind 'o')"
expect_eq "s.index hit"             "6"               "$(echo 'hello world' | s.index 'world')"
expect_eq "s.partition hit"         $'he\nl\nlo'      "$(echo 'hello' | s.partition 'l')"
expect_eq "s.partition miss"        "hello"           "$(echo 'hello' | s.partition 'z')"
expect_eq "s.rpartition"            $'hel\nl\no'      "$(echo 'hello' | s.rpartition 'l')"
expect_eq "s.removeprefix hit"      "world"           "$(echo 'helloworld' | s.removeprefix 'hello')"
expect_eq "s.removeprefix miss"     "helloworld"      "$(echo 'helloworld' | s.removeprefix 'xyz')"
expect_eq "s.removesuffix hit"      "hello"           "$(echo 'helloworld' | s.removesuffix 'world')"
expect_eq "s.expandtabs default"    "a       b"       "$(printf 'a\tb' | s.expandtabs)"
expect_eq "s.expandtabs 4"          "a   b"           "$(printf 'a\tb' | s.expandtabs 4)"
expect_eq "s.translate basic"       "xyz"             "$(echo 'abc' | s.translate 'abc' 'xyz')"

# --- v2: predicates ---
expect_eq "s.isupper filter"   $'ABC\nXYZ'    "$(printf 'ABC\naBc\nXYZ\n' | s.isupper)"
expect_eq "s.islower filter"   "abc"          "$(printf 'abc\nABC\n' | s.islower)"
expect_eq "s.isdigit filter"   $'123\n42'     "$(printf '123\nabc\n42\n12.3\n' | s.isdigit)"
expect_eq "s.isalpha filter"   "abc"          "$(printf 'abc\nab1\n' | s.isalpha)"
expect_eq "s.isalnum filter"   $'abc\nab1'    "$(printf 'abc\nab1\nab 1\n' | s.isalnum)"
expect_eq "s.isspace filter"   "   "          "$(printf '   \nabc\n' | s.isspace)"
expect_eq "s.isascii filter"   "abc"          "$(printf 'abc\ncafé\n' | s.isascii)"
expect_eq "s.isdigit no match" ""             "$(printf 'abc\nxyz\n' | s.isdigit)"

# --- v2: format ---
expect_eq "s.format basic"          "Hello, world!"                    "$(echo 'world' | s.format 'Hello, {}!')"
expect_eq "s.format per-line"       $'> Alice\n> Bob'                  "$(printf 'Alice\nBob\n' | s.format '> {}')"
expect_eq "s.format positional"     "Length: abc chars: [abc]"         "$(echo 'abc' | s.format 'Length: {0} chars: [{0}]')"
expect_eq "s.format escape literal" "{not a placeholder}"              "$(echo 'x' | s.format '{{not a placeholder}}')"

# --- v2: regex ---
expect_eq "s.re_replace basic"     "X X X"          "$(echo 'foo bar baz' | s.re_replace '\w+' 'X')"
expect_eq "s.re_replace backref"   "BAR foo"        "$(echo 'foo BAR' | s.re_replace '(\w+) (\w+)' '\2 \1')"
expect_eq "s.re_match filter"      $'foo123\n42abc' "$(printf 'foo123\nbar\n42abc\n' | s.re_match '[0-9]+')"
expect_eq "s.re_find whole match"  $'42\n7'         "$(echo 'price 42 qty 7' | s.re_find '[0-9]+')"
expect_eq "s.re_find capture grp"  $'foo\nbar'      "$(echo 'foo=1 bar=2' | s.re_find '(\w+)=\d+')"
expect_eq "s.re_split basic"       $'a\nb\nc'       "$(echo 'a,,b;c' | s.re_split '[,;]+')"

# --- v2: text shaping ---
expect_eq "s.wrap 10"         $'hello\nworld foo\nbar'    "$(echo 'hello world foo bar' | s.wrap 10)"
expect_eq "s.truncate fit"    "abc"                       "$(echo 'abc' | s.truncate 5)"
expect_eq "s.truncate cut"    "ab…"                       "$(echo 'abcdef' | s.truncate 3)"
expect_eq "s.truncate suffix" "abc..."                    "$(echo 'abcdefgh' | s.truncate 6 '...')"
expect_eq "s.prefix"          $'> a\n> b'                 "$(printf 'a\nb\n' | s.prefix '> ')"
expect_eq "s.suffix"          $'a;\nb;'                   "$(printf 'a\nb\n' | s.suffix ';')"
expect_eq "s.indent 4"        $'    a\n    b'             "$(printf 'a\nb\n' | s.indent 4)"
expect_eq "s.indent custom"   $'..a\n..b'                 "$(printf 'a\nb\n' | s.indent 2 .)"
expect_eq "s.dedent basic"    $'a\nb'                     "$(printf '    a\n    b\n' | s.dedent)"

# --- v2: case converters ---
expect_eq "s.snake camelCase"    "hello_world"        "$(echo 'helloWorld' | s.snake)"
expect_eq "s.snake PascalCase"   "hello_world"        "$(echo 'HelloWorld' | s.snake)"
expect_eq "s.snake kebab-case"   "hello_world"        "$(echo 'hello-world' | s.snake)"
expect_eq "s.snake XMLParser"    "xml_parser"         "$(echo 'XMLParser' | s.snake)"
expect_eq "s.snake spaces"       "hello_world_foo"    "$(echo 'hello world foo' | s.snake)"
expect_eq "s.kebab camelCase"    "hello-world"        "$(echo 'helloWorld' | s.kebab)"
expect_eq "s.camel snake_case"   "helloWorld"         "$(echo 'hello_world' | s.camel)"
expect_eq "s.camel kebab-case"   "helloWorld"         "$(echo 'hello-world' | s.camel)"
expect_eq "s.pascal snake_case"  "HelloWorld"         "$(echo 'hello_world' | s.pascal)"
expect_eq "s.pascal XMLParser"   "XmlParser"          "$(echo 'XMLParser' | s.pascal)"
expect_eq "s.const camelCase"    "HELLO_WORLD"        "$(echo 'helloWorld' | s.const)"

echo ""
echo "passed: $passed  failed: $failed"
exit $(( failed > 0 ? 1 : 0 ))
