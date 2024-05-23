{ pkgs, lib, inputs, ... }:

let
  pyenv = inputs.poetry2nix.legacyPackages.${pkgs.system}.mkPoetryEnv {
    projectDir = "";
    preferWheels = true;
    pyproject = ./pyproject.toml;
    poetrylock = ./poetry.lock;
    python = pkgs.python3;
  };
in
{
  # https://devenv.sh/basics/
  env = {
    PROJECT = "poetry2nix-template";

    # context for taskwarrior
    TW_CONTEXT = "tfm";

    PYTHON = lib.getExe pyenv;
    PYTHONHOME = pyenv;
  };

  # https://devenv.sh/scripts/
  scripts = {
    # build-doc.exec = ''
    #   latexmk -cd "$DEVENV_ROOT/document/000-main.tex" -lualatex -shell-escape -interaction=nonstopmode -file-line-error -view=none "$@"
    # '';
    #
    # # Download bibliography from local zotero instance (using better-bibtex plugin)
    # fetch-biblio.exec = ''
    #   curl -f http://127.0.0.1:23119/better-bibtex/export/collection?/1/TFM.biblatex -o "$DEVENV_ROOT/document/biblio.bib" || echo "Is Zotero running?"
    # '';
    #
    # pluto.exec = "julia --project=$DEVENV_ROOT -e 'using Pkg; Pkg.instantiate(); using Pluto; Pluto.run(auto_reload_from_file=true)'";
    #
    # sync-pycall-deps.exec = "julia ${./julia_link_pycall.jl}";
  };

  enterShell = '''';

  packages = with pkgs; [
    poetry2nix.packages.${system}.poetry
    pyenv
  ];

  # # https://devenv.sh/languages/
  # languages = {
  #   nix.enable = true;
  #
  #   r = {
  #     enable = true;
  #     package = pkgs.symlinkJoin {
  #       name = "R";
  #       paths = [ Renv ];
  #       buildInputs = [ pkgs.makeWrapper ];
  #       postBuild = ''
  #         wrapProgram "$out/bin/R" --set R_LIBS_SITE ""
  #       '';
  #     };
  #   };
  #
  #   julia = {
  #     enable = true;
  #     package = pkgs.julia_19;
  #   };
  # };

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks = {
  #   chktex.enable = true;
  #   nixpkgs-fmt.enable = true;
  #   ruff.enable = true;
  #   shellcheck.enable = true;
  # };

  # # https://devenv.sh/processes/
  # processes = {
  #   # jupyter.exec = "jupyter lab";
  #   latexmk.exec = "build-doc -pvc";
  #   pluto.exec = "pluto";
  # };
}
