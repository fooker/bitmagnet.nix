{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    bash
    git
    openjdk17
    maven
  ];
}
