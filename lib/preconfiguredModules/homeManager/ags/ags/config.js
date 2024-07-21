const hyprland = await Service.import("hyprland")
const notifications = await Service.import("notifications")
//const mpris = await Service.import("mpris")
const audio = await Service.import("audio")
const battery = await Service.import("battery")
const systemtray = await Service.import("systemtray")

const date = Variable("", {
    poll: [1000, 'date "+%H:%M:%S %b %e, %Y"'],
})

function Clock() {
    return Widget.Label({
        css: "font-size: 24px; padding: 16px;",
        label: date.bind().as(d => `  ${d}`),
    })
}

function Volume() {
    const icons = {
        101: "overamplified",
        67: "high",
        34: "medium",
        1: "low",
        0: "muted",
    }

    function getIcon() {
        const icon = audio.speaker.is_muted ? 0 : [101, 67, 34, 1, 0].find(
            threshold => threshold <= audio.speaker.volume * 100)

        return `audio-volume-${icons[icon]}-symbolic`
    }

    const icon = Widget.Icon({
        icon: Utils.watch(getIcon(), audio.speaker, getIcon),
    })

    const slider = Widget.Slider({
        hexpand: true,
        draw_value: false,
        vertical: true,
        on_change: ({ value }) => audio.speaker.volume = value,
        setup: self => self.hook(audio.speaker, () => {
            self.value = audio.speaker.volume || 0
        }),
    })

    return Widget.Box({
        class_name: "volume",
        css: "min-width: 180px",
        children: [icon, slider],
    })
}

//const players = mpris.bind("players")

const FALLBACK_ICON = "audio-x-generic-symbolic"
const PLAY_ICON = "media-playback-start-symbolic"
const PAUSE_ICON = "media-playback-pause-symbolic"
const PREV_ICON = "media-skip-backward-symbolic"
const NEXT_ICON = "media-skip-forward-symbolic"

/** @param {number} length */
function lengthStr(length) {
    const min = Math.floor(length / 60)
    const sec = Math.floor(length % 60)
    const sec0 = sec < 10 ? "0" : ""
    return `${min}:${sec0}${sec}`
}

/** @param {import('types/service/mpris').MprisPlayer} player */
function Player(player) {
    const img = Widget.Box({
        class_name: "img",
        vpack: "start",
        css: player.bind("cover_path").transform(p => `
            background-image: url('${p}');
        `),
    })

    const title = Widget.Label({
        class_name: "title",
        wrap: true,
        hpack: "start",
        label: player.bind("track_title"),
    })

    const artist = Widget.Label({
        class_name: "artist",
        wrap: true,
        hpack: "start",
        label: player.bind("track_artists").transform(a => a.join(", ")),
    })

    const positionSlider = Widget.Slider({
        class_name: "position",
        draw_value: false,
        on_change: ({ value }) => player.position = value * player.length,
        visible: player.bind("length").as(l => l > 0),
        setup: self => {
            function update() {
                const value = player.position / player.length
                self.value = value > 0 ? value : 0
            }
            self.hook(player, update)
            self.hook(player, update, "position")
            self.poll(1000, update)
        },
    })

    const positionLabel = Widget.Label({
        class_name: "position",
        hpack: "start",
        setup: self => {
            const update = (_, time) => {
                self.label = lengthStr(time || player.position)
                self.visible = player.length > 0
            }

            self.hook(player, update, "position")
            self.poll(1000, update)
        },
    })

    const lengthLabel = Widget.Label({
        class_name: "length",
        hpack: "end",
        visible: player.bind("length").transform(l => l > 0),
        label: player.bind("length").transform(lengthStr),
    })

    const icon = Widget.Icon({
        class_name: "icon",
        hexpand: true,
        hpack: "end",
        vpack: "start",
        tooltip_text: player.identity || "",
        icon: player.bind("entry").transform(entry => {
            const name = `${entry}-symbolic`
            return Utils.lookUpIcon(name) ? name : FALLBACK_ICON
        }),
    })

    const playPause = Widget.Button({
        class_name: "play-pause",
        on_clicked: () => player.playPause(),
        visible: player.bind("can_play"),
        child: Widget.Icon({
            icon: player.bind("play_back_status").transform(s => {
                switch (s) {
                    case "Playing": return PAUSE_ICON
                    case "Paused":
                    case "Stopped": return PLAY_ICON
                }
            }),
        }),
    })

    const prev = Widget.Button({
        on_clicked: () => player.previous(),
        visible: player.bind("can_go_prev"),
        child: Widget.Icon(PREV_ICON),
    })

    const next = Widget.Button({
        on_clicked: () => player.next(),
        visible: player.bind("can_go_next"),
        child: Widget.Icon(NEXT_ICON),
    })

    return Widget.Box(
        { class_name: "player" },
        img,
        Widget.Box(
            {
                vertical: true,
                hexpand: true,
            },
            Widget.Box([
                title,
                icon,
            ]),
            artist,
            Widget.Box({ vexpand: true }),
            positionSlider,
            Widget.CenterBox({
                start_widget: positionLabel,
                center_widget: Widget.Box([
                    prev,
                    playPause,
                    next,
                ]),
                end_widget: lengthLabel,
            }),
        ),
    )
}

function Media() {
    return Widget.Box({
        vertical: true,
        css: "min-height: 2px; min-width: 2px;", 
        visible: players.as(p => p.length > 0),
        children: players.as(p => p.map(Player)),
    })
}

function SysTray() {
    const items = systemtray.bind("items")
        .as(items => items.map(item => Widget.Button({
            css: "padding: 14px 16px; border: 2px solid #b7bdf8; border-radius: 50%",
            child: Widget.Icon({ icon: item.bind("icon") }),
            on_primary_click: (_, event) => item.activate(event),
            on_secondary_click: (_, event) => item.openMenu(event),
            tooltip_markup: item.bind("tooltip_markup"),
        })))

    return Widget.Box({
        css: "padding: 10px",
        spacing: 8,
        children: items,
    })
}


function Workspaces() {
    const activeId = hyprland.active.workspace.bind("id")
    const workspaces = hyprland.bind("workspaces")
        .as(ws => ws.map(({ id }) => Widget.Button({
            css: "margin: 4px 4px; border: 2px solid #b7bdf8; border-radius: 5px;",
            on_clicked: () => hyprland.messageAsync(`dispatch workspace ${id}`),
            child: Widget.Label({
                css: "padding: 11px 16px; font-size: 20px;",
                label: `${id}`
            }),
            class_name: activeId.as(i => `${i === id ? "focused" : ""}`),
        })))

    return Widget.Box({
        css: "padding: 1px 1px; ",
        class_name: "workspaces",
        children: workspaces,
    })
}



App.config({
    windows: [
        Widget.Window({
            name: "clock",
            visible: false,
            anchor: ["top"],
            margins: [64, 64],
            child: Clock()
        }),
        Widget.Window({
            name: "control",
            visible: false,
            anchor: ["top"],
            margins: [128, 64],
            css: "all: unset; background-color: rgba(0, 0, 0, 0)",
            child: Widget.Box({
                hpack: "center",
                spacing: 8,
                children: [
                    Widget.Button({
                        css: "padding: 14px 20px; color: #f5a97f; border: 2px solid #b7bdf8; border-radius: 50%",
                        child: Widget.Label("󰐥"),
                        onClicked: () => Utils.exec("systemctl poweroff")
                    }),
                    Widget.Button({
                        css: "padding: 14px 20px; border: 2px solid #b7bdf8; border-radius: 50%",
                        child: Widget.Label("󰑓"),
                        onClicked: () => Utils.exec("systemctl reboot")
                    }),
                    Widget.Button({
                        css: "padding: 14px 20px; border: 2px solid #b7bdf8; border-radius: 50%",
                        child: Widget.Label("󰒲"),
                        onClicked: () => Utils.exec("systemctl suspend")
                    }),
                    Widget.Button({
                        css: "padding: 14px 20px; border: 2px solid #b7bdf8; border-radius: 50%",
                        child: Widget.Label("󰍃"),
                        onClicked: () => Utils.exec("loginctl terminate-user $USER")
                    }),
                ]
            })
        }),
        Widget.Window({
            name: "systray",
            visible: false,
            anchor: ["top", "right"],
            margins: [64, 64],
            css: "all: unset; background-color: rgba(0, 0, 0, 0)",
            child: SysTray()
        }),
        Widget.Window({
            name: "workspaces",
            visible: false,
            anchor: ["bottom"],
            margins: [64, 64],
            css: "all: unset; background-color: rgba(0, 0, 0, 0)",
            child: Workspaces()
        }),
        Widget.Window({
            name: "window-title",
            visible: false,
            anchor: ["bottom"],
            margins: [128, 64],
            css: "all: unset; background-color: rgba(0, 0, 0, 0)",
            child: Widget.Label({
                css: "color: #c6a0f6; padding: 1px 1px",
                label: hyprland.active.client.bind("title")
            })
        })
    ],
})

App.applyCss(`
    window {
        background-color: #24273a;
        opacity: 0.95;
        color: #cad3f5;
        border: 2px solid #b7bdf8;
        border-radius: 5px;
    }

    menu {
        background-color: #24273a;

    }

    button {
        all: unset;
        font-size: 20px;
        background-color: #24273a;
        border-style: solid;
        border-left: 2px;
        border-color: #3b4261;
    }

    button:hover {
        background-color: #3b4261;
        transition: 0.5s;
    }

    .workspaces button.focused {
        background-color: #494d64;
    }

    .player {
        padding: 10px;
        min-width: 350px;
    }

    .player .img {
        min-width: 100px;
        min-height: 100px;
        background-size: cover;
        background-position: center;
        border-radius: 13px;
        margin-right: 1em;
    }

    .player .title {
        font-size: 1.2em;
    }

    .player .artist {
        font-size: 1.1em;
        color: @insensitive_fg_color;
    }

    .player scale.position {
        padding: 0;
        margin-bottom: .3em;
    }

    .player scale.position trough {
        min-height: 8px;
    }

    .player scale.position highlight {
        background-color: @theme_fg_color;
    }

    .player scale.position slider {
        all: unset;
    }

    .player button {
        min-height: 1em;
        min-width: 1em;
        padding: .3em;
    }

    .player button.play-pause {
        margin: 0 .3em;
    }
`)

export {}
