<img src="https://cdn.rawgit.com/oh-my-fish/oh-my-fish/e4f1c2e0219a17e2c748b824004c8d0b38055c16/docs/logo.svg" align="left" width="144px" height="144px"/>

#### Dotfish
> A plugin for [Fish][fish-link] to automatically source a `.fish` file when entering a folder.

[![MIT License](https://img.shields.io/badge/license-MIT-007EC7.svg?style=flat-square)](/LICENSE)
[![Fish Shell Version](https://img.shields.io/badge/fish-v3.3.0-007EC7.svg?style=flat-square)](https://fishshell.com)
[![Oh My Fish Framework](https://img.shields.io/badge/Oh%20My%20Fish-Framework-007EC7.svg?style=flat-square)](https://www.github.com/oh-my-fish/oh-my-fish)

<br/>


## Install

Install Dotfish manually...
```
curl https://raw.githubusercontent.com/enerdgumen/dotfish/main/conf.d/dotfish.fish \
    -o ~/.config/fish/conf.d/dotfish.fish
```

...or via [Oh My Fish][omf-link] (unavailable at the moment):
```
omf install dotfish
```

## Usage

Run `dotfish on` from a folder you want to work on. Dotfish by default creates a `.fish` file including an example `hello` command.

Now, every time you browse such a folder, the shell will automatically load .fish showing all the variables and functions loaded into the session.
All these symbols are unloaded when you move out from the folder.

Run `dotfish` to see a detail of the loaded symbols.

After updating the .fish file, you have to explicitly re-enable Dotfish on that folder by running `dotfish on` again.
If you are unsure, run `dotfish diff` to see any difference between the preview .fish version and the current one.

Finally, run `dotfish unload` to temporarily unload the symbols or `dotfish off` to unload them and permanently disable Dotfish on that folder.

## Why did I write this?

I often develop directly from Docker containers and I wanted a way to work with them in a transparent way, using the commands available in the containers as if they were local.

For example, for Elixir projects I generally have a .fish like the following:

```fish
function up
  if test (docker ps -q -f name=dev | wc -l) -eq 0
    docker-compose up -d
  end
end

function mix --wraps=/usr/local/bin/mix
  up && docker exec -it dev mix $argv
end

function iex --wraps=/usr/local/bin/iex
  up && docker exec -it dev iex $argv
end
```

After entering the project folder, executing `mix build` automatically starts the stack and runs the command in the dev container!

## Integrations

The `__dotfish_loaded` environment variable is set when .fish is loaded in the current session.

This is an example of [Starship](https://starship.rs) configuration:

```toml
[custom.dotfish]
when = """ test -n "$__dotfish_loaded" """
symbol = "🐠"
```

## Security considerations

In order to prevent remote command execution, Dotfish requires that you explicitly enable a folder to autoload the .fish file.
Dotfish will not load the file anymore if the folder path or the file content changes. To do this, Dotfish keeps an index of all the enabled folders in `~/.dotfish/index`, together with a copy of each involved .fish file.

If you find any security issues, please report them.

# License

[MIT][mit] © [Mauro Rocchi][author] et [al][contributors]


[mit]:            https://opensource.org/licenses/MIT
[author]:         https://github.com/enerdgumen
[contributors]:   https://github.com/enerdgumen/dotfish/graphs/contributors
[fish-link]:      https://fishshell.com
[omf-link]:       https://www.github.com/oh-my-fish/oh-my-fish
[license-badge]:  https://img.shields.io/badge/license-MIT-007EC7.svg?style=flat-square
