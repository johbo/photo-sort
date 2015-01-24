
============
 Photo Sort
============

Small example application to learn how to develop in D.

The project can be build and run based on `dub`::

   dub build
   ./photo-sort --help


A good starting point to find out more about how to set up the
required tool chain is http://dlang.org.



Nix support
===========

The project can also be set up with tools from
http://nixos.org. Currently you need the following things for this to
work:

- Nix package manager

  Follow the instructions on http://nixos.org/nix. Afterwards commands
  like `nix-env` or `nix-shell` should be available.

  Note that this is not needed if you are using NixOS obviously.

- Currently needed: Get a recent clone of `nixpkgs`

  .. code::

     # Assumed you are placing things into ~/dev
     cd ~/dev
     git clone https://github.com/NixOS/nixpkgs.git

- Enter "development" shell and build

  .. code::

     nix-shell -I ~/dev
     dub build

