# import typing as ty

import typer

app = typer.Typer()

@app.callback(invoke_without_command=True)
def main():
    print("hi :3")
