{
  pkgs ? import <nixpkgs> { },
  ...
}:
pkgs.mkShell {
  nativeBuildInputs = [
    pkgs.git
    # pkgs.zed-editor # we often need to run on unconfigured machines, so we provide an editor

    pkgs.pyright
    pkgs.python312
    pkgs.ruff
    pkgs.ty # inshallah
    pkgs.uv
  ];

  shellHook = ''
    export PROJECT_ROOT="$PWD"
    export PATH="$PWD/devprefix/bin:$PATH"
    uv sync || true
    . .venv/bin/activate
    export PYTHONPATH="$PWD/.venv/lib/python3.12/site-packages:$PYTHONPATH"
  '';
}
