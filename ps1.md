# Custom Bash shell prompt `$PS1`

## Examples

### Default Bash prompt

The [default Bash shell prompt](https://manpages.debian.org/bullseye/bash/bash.1.en.html#PS1) if not set in any profile (`.bashrc`, `.profile`)

```sh
PS1="\s-\v\$ "
# > "bash-5.1$ "
```

- "`\s`" (shell name) becomes "`bash`"
- "`-`" stays "`-`"
- "`\v`" (version) becomes "`5.1`"
- "`\$`" escapes "`$`"
- "` `" stays "` `"

### Default Debian Bash prompt

The prompt set in the skeleton `.bashrc` on a freshly installed Debian system.

```sh
PS1="\[\e[1;32m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ "
# > "junaga@home-box:/etc/apt$ "
# > "junaga@home-box:~$ "
# > "root@home-box:/$ "
```

- "`\[\e[1;32m\]`" bold and green, color begin
- "`\u`" (username) becomes "`junaga`"
- "`@`" stays "`@`"
- "`\h`" (hostname) becomes "`home-box`"
- "`\[\e[0m\]`" reset, color end
- "`:`" stays "`:`"
- "`\[\e[1;34m\]`" bold and blue, color begin
- "`\w`" (present working directory, or "`~`") for example "`/etc/apt`"
- "`\[\e[0m\]`" reset, color end
- "`\$`" escapes "`$`"
- "` `" stays "` `"

### My Bash prompt (needs `git`)

The prompt I use in my `$HOME/.profile` everyday. It needs "apt:git" installed, but shows the checked out branch.

```sh
PS1="\A \[\e[1;34m\]\w\[\e[0m\]\$(__git_ps1 '|%s')\$ "
# > "14:57 /etc/apt$ "
# > "14:35 ~/src/app|main$ "
# > "00:00 /$ "
```

- "`\A`" (time in HH:MM) for example "`14:57`"
- "` `" stays "` `"
- "`\[\e[1;34m\]`" bold blue, color begin
- "`\w`" (present working directory, or "`~`") for example "`/etc/apt`"
- "`\[\e[0m\]`" reset, color end
- "`\$(__git_ps1 '|%s')`" \
  Subshell that invoces a function from `git`. If the present working directory is a git repository, the expression evaluates to the repositorie's checked out branch with a leading `"|"`. So `"|main"` or `"|fix-account-signup"`. A string is only returned by `__git_ps1` if a repo is checked out. So `"|"` itself is never returned under any circumstances.
- "`\$`" escapes "`$`"
- "` `" stays "` `"

## [Bash prompt escape characters](https://manpages.debian.org/bullseye/bash/bash.1.en.html#PROMPTING)

These are special variables replaced by the shell on prompt, for example.

- `\u` - username
- `\h` - hostname
- `\w` - present working directory

## [ANSI color codes](https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit)

Terminal, ANSI Escape Code, Control Sequence Introducer, Select Graphic Rendition, 3-bit color, parameters - or simply **ANSI color codes**.

Colors are set with the numbers `30`-`37`, and background colors with `40`-`47` (in the same order). In between `\e[` and `m`, seperated by `;`.

1. Terminal escape sequences start with an [Escape](https://en.wikipedia.org/wiki/ASCII#:~:text=001%201011,Escape%5Bj%5D) `\e` character.
2. Before the color code comes an `[` literall. Start with `\e[`
3. A _Select Graphic Rendition Parameter_
   - `0` - Reset all previously applied parameters
   - `1` - Bold text (Bright)
   - `2` - Faint text (Dim)
   - `30`- Black
   - `31` - Red
   - `32` - Green
   - `33` - Yellow
   - `34` - Blue
   - `35` - Magenta
   - `36` - Cyan
   - `37` - White
   - `40`-`47` - Background color, same order as `30`-`37`
4. (optional) paramters can be chained with `;`
5. An `m` literall

```sh
# bold, blue text
\e[1;34m
# bold, white text, on red background
\e[37;41;1m
# green text
\e[32m
# green background
\e[42m
```

### Usage on Bash prompt

Unfortunately the color code itself is _not enough to make it work good_ on the Bash prompt. The problem is that Bash needs to know in advance how many character long the prompt will be. If you add color codes on the prompt bash will misscount the length, and the shell cursor and terminal cursor will missalign, which causes line wrapping issues. Bash has [it's own escape for this](https://manpages.debian.org/bullseye/bash/bash.1.en.html#:~:text=%5C%5B,end%20a%20sequence%20of%20non%2Dprinting%20characters), just wrap any terminal escape sequence in `\[` `\]`.

> `\[` begin a sequence of non-printing characters, which could be used to embed a terminal control sequence into the prompt

> `\]` end a sequence of non-printing characters

```sh
# bold, blue text
\[\e[1;34m\]
# bold, white text, on red background
\[\e[37;41;1m\]
# green text
\[\e[32m\]
# green background
\[\e[42m\]
```

After you color your text, always remember to reset it.

```sh
# reset all previous
\[\e[0m\]
```

Different terminals, _serial hardware terminals or emulated terminals_, render the ANSI color codes differently (see the wikipedia article). On Unix systems the environment variable `$TERM` can be used to determine the terminal. For PC the emulated "xterm" is used in javascript (Web pages), Microsoft Windows Terminal, and X based Linux distros. Only "Terminal.app" on macOS PCs has a different color profile then "xterm". Older PC systems and mainframes have entirely different terminal color profiles. But the ANSI Escape sequences themselfs work everywhere, even on 40 year old IBM mainframes. Doesn't hugely matter if the blue looks like a weak purple.
