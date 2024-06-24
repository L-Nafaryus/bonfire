#!/usr/bin/env python3

import click
import subprocess
import json

@click.group()
def cli():
    pass

@cli.command()
def xkblayout():
    p = subprocess.run("hyprctl devices -j", capture_output = True, shell = True)
    devices = json.loads(p.stdout)

    for keyboard in devices["keyboards"]:
        if keyboard["name"] == "keychron-keychron-k3-pro":
            click.echo(keyboard["active_keymap"][ :2].lower(), nl = False)

@cli.command()
@click.option("--action", "-a", type = click.Choice(["buttons", "current", "count"]))
def workspace(action):
    p = subprocess.run("hyprctl workspaces -j", capture_output = True, shell = True)
    workspaces = json.loads(p.stdout)
    p = subprocess.run("hyprctl activeworkspace -j", capture_output = True, shell = True)
    current_workspace = json.loads(p.stdout)

    match action:
        case "buttons":
            buttons = ""
            for workspace in workspaces:
                css = ':css "button {background-color: #3b4261}"' if workspace["id"] == current_workspace["id"] else ""
                buttons += '(button {} :width "40" :onclick "hyprctl dispatch workspace {}" "{}") ' \
                    .format(css, workspace["id"], workspace["id"])
            click.echo(f'(box {buttons})', nl = False)
        case "current":
            click.echo(current_workspace["id"], nl = False)
        case "count":
            click.echo(len(workspaces), nl = False)

@cli.command()
def get_volume():
    p = subprocess.run("wpctl get-volume @DEFAULT_AUDIO_SINK@", capture_output = True, shell = True)
    volume_status = p.stdout.decode().replace("\n", "").split(" ")
    volume = volume_status[1]
    icon = "" if volume_status[-1] == "[MUTED]" else ""
    click.echo(f"{volume} {icon}", nl = False)

if __name__ == "__main__":
    cli()
