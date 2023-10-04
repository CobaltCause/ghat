# Contributing

## Development requirements

1. Install [Nix][nix] and enable support for [flakes][flakes]
2. Install [direnv][direnv] and [nix-direnv][nix-direnv]
3. If using a graphical editor, install an extension to give it direnv support.
   If no such extension is available, `cd`ing into the project directory
   and launching the editor from the terminal should cause it to inherit the
   environment; though the editor will likely need to be restarted to propagate
   any changes to the direnv setup to the editor if any such changes are made.

[nix]: https://nixos.org/download.html
[flakes]: https://nixos.wiki/wiki/Flakes#Enable_flakes
[direnv]: https://direnv.net/docs/installation.html
[nix-direnv]: https://github.com/nix-community/nix-direnv#installation
