
def is-installed [ app: string ] {
    ((which $app | length) > 0)
}

export def healthcheck []: nothing -> nothing {
    let rofi_installed = is-installed "rofi";
    let rofi_wayland = if $rofi_installed {
      "wayland" in (rofi -version);
    } else {
      false;
    }

    print $"* rofi: installed - ($rofi_installed), wayland support - ($rofi_wayland)";
}

export def powermenu []: nothing -> nothing {
    let uptime = (sys host).uptime;
    let action = [lock suspend logout reboot shutdown];
    mut selected = null;
  
    $selected = $action | to text | rofi -dmenu -p (date now | format date "%Y-%m-%d %H:%M:%S") -mesg $"Uptime: ($uptime)" -theme powermenu.rasi;

    match $selected {
      "lock" => { hyprlock --immediate; }
      "suspend" => { systemctl suspend; }
      "logout" => { hyprctl dispatch exit; }
      "reboot" => { systemctl reboot; }
      "shutdown" => { systemctl poweroff; }
      _ => break 
    }
}

export def apps []: nothing -> nothing {
    rofi -show drun window -theme apps.rasi;
}
