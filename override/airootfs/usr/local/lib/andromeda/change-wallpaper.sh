#!/bin/bash
# set Andromeda wallpaper

change-wallpaper() {
    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript '
        var allDesktops = desktops();
        print (allDesktops);
        for (i=0;i<allDesktops.length;i++) {{
            d = allDesktops[i];
            d.wallpaperPlugin = "org.kde.image";
            d.currentConfigGroup = Array("Wallpaper",
                                         "org.kde.image",
                                         "General");
            d.writeConfig("Image", "file:///usr/local/share/andromeda/andromeda_wallpaper.png")
        }}
    '
}

until change-wallpaper; do sleep 1; done

rm ~/.config/autostart/change-wallpaper.desktop