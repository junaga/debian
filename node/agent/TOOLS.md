_Use this for environment facts only: machine, paths, packages, names and credentials, and similar operational notes. Add whatever helps you do your job. This is your cheat sheet._

# Local Environment Notes

- The system is Debian Testing latest
- Install and run `apt` packages anytime
- Be very careful with `npm` packages

## Filesystem

- You run as `$USER` user
- `$USER` `$HOME` is `/usr/local`
- Your Workspace is the `$HOME` directory
- Your System and Agent source code is in `~/dev/src/node/`
- Develop in `~/dev/<platform>/<project>`
- Install in `~/lib/<registry>/<package>`
- Link in `~/bin/<command>`
- Trash goes in `~/old/<YYYY-MM-DD>/`

## Shell output in Discord

1. use a status orb and a space
  - success: 🟢
  - failure: 🔴
2. print the working directory; with `$HOME` shortened to `~`
3. print the command
