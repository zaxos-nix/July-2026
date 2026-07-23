{ ... }: {
  # ════════════════════════════════════════════════════════════════
  # GTK icon theme — Nautilus (and any other GTK3/4 app) has nothing
  # telling it which icon set to use. With no home-manager and no
  # GNOME session running, there's no dconf default and no
  # ~/.config/gtk-4.0/settings.ini being written by anything, so GTK
  # falls back to whatever's bundled — which in practice is close to
  # nothing, since hicolor-icon-theme is just an empty fallback spec,
  # not an actual icon set. That's the "unthemed" look.
  #
  # Two things fix it:
  #   1. programs.dconf.enable — GTK apps use dconf as their settings
  #      backend; without it running, some GTK theming/behavior is
  #      undefined even with the right files in place.
  #   2. A system-wide gtk-4.0/gtk-3.0 settings.ini under /etc/xdg —
  #      GTK reads $XDG_CONFIG_HOME/gtk-X.0/settings.ini first, then
  #      falls back to $XDG_CONFIG_DIRS (which includes /etc/xdg by
  #      default), so this acts as a system default every GTK app
  #      picks up without needing a per-user dotfile.
  #
  # NOTE on matugen: matugen's own gtk template (if you have one)
  # writes ~/.config/gtk-4.0/gtk.css / gtk-3.0/gtk.css for *color*
  # theming (widget colors, accent color). That's separate from,
  # and doesn't conflict with, gtk-icon-theme-name below — colors and
  # icon-set selection are two different settings.
  # ════════════════════════════════════════════════════════════════
  flake.nixosModules.gtkTheming = { pkgs, ... }: {
    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; [
      adwaita-icon-theme
      # Swap/add for a more colorful set, e.g.:
      # papirus-icon-theme
    ];

    environment.etc."xdg/gtk-3.0/settings.ini".text = ''
      [Settings]
      gtk-icon-theme-name=Adwaita
      gtk-theme-name=Adwaita
      gtk-application-prefer-dark-theme=1
    '';

    environment.etc."xdg/gtk-4.0/settings.ini".text = ''
      [Settings]
      gtk-icon-theme-name=Adwaita
      gtk-application-prefer-dark-theme=1
    '';
  };
}
