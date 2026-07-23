# Shared Home Manager config imported by izo, zax, and izax.
# Anything that should be identical for every user on this machine goes here;
# desktop/compositor-specific bits live in each user's own file.
{ pkgs, ... }: {
  home.stateVersion = "26.11";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "izone-nix";
    userEmail = "self@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # ── Ghostty ──
  # Declared here (rather than left as a plain package in each user's
  # home.packages) so gtk-single-instance can be turned off: with it on
  # (the default), a running Ghostty just opens a new tab wherever it
  # already is instead of honoring --working-directory, which breaks the
  # Nautilus "Open in Ghostty" entry (modules/hosts/my-machine's
  # programs.nautilus-open-any-terminal) — it'd open, but always in the
  # wrong folder.
  programs.ghostty = {
    enable = true;
    settings = {
      gtk-single-instance = false;
    };
  };

  programs.fish = {
    enable = true;
    shellAliases = {
      # nixos
      nrs  = "sudo nixos-rebuild switch --flake ~/myNixos#myMachine";
      nrb  = "sudo nixos-rebuild boot --flake ~/myNixos#myMachine";
      nfu  = "nix flake update --flake ~/myNixos";

      # filesystem
      ll   = "ls -lah";
      la   = "ls -A";
      ".." = "cd ..";
      y    = "yazi";

      # git
      g    = "git";
      gs   = "git status";
      ga   = "git add";
      gc   = "git commit -m";
      gp   = "git push";
      gl   = "git pull";
      gd   = "git diff";
      gco  = "git checkout";
      gb   = "git branch";
    };
  };

  # ── Drive auto-discovery (user-session half) ──
  # services.udisks2 (system side, in modules/features/drive-automount.nix)
  # detects NTFS/exFAT/USB drives; udiskie automounts them the moment they're
  # plugged in and gives every session a tray icon + notification for it,
  # which niri/mango don't provide out of the box the way GNOME did.
  services.udiskie = {
    enable = true;
    tray = "auto";
    automount = true;
    notify = true;
  };

  # ── Shared core folders ──
  # The actual directories (owned by root:shared, setgid) are created once by
  # modules/features/shared-folders.nix. This just points each user's XDG
  # dirs at that shared tree instead of a private ~/Documents, ~/Downloads,
  # etc., so izo/zax/izax all read and write the same files.
  xdg.userDirs = {
    enable = true;
    createDirectories = false;
    desktop = "/home/Shared/Desktop";
    documents = "/home/Shared/Documents";
    download = "/home/Shared/Downloads";
    music = "/home/Shared/Music";
    pictures = "/home/Shared/Pictures";
    videos = "/home/Shared/Videos";
    publicShare = "/home/Shared/Public";
    templates = "/home/Shared/Templates";
  };

  home.packages = with pkgs; [
    fastfetch
    htop
    mpv
    zathura
    pcmanfm
    yazi
    imv
  ];

  # ── GTK / libadwaita theming ──
  # Nothing else in this config sets a color-scheme or icon theme, so
  # GTK4/libadwaita apps (Nautilus chief among them) were falling back to
  # plain light Adwaita — the one thing that actually controls Nautilus's
  # dark mode is the "color-scheme" dconf key below, not a legacy GTK theme
  # (libadwaita apps ignore most of those). adw-gtk3 is included too so
  # older GTK3 apps look consistent with it rather than mismatched.
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
  };

  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  dconf.enable = true;
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "adw-gtk3-dark";
    icon-theme = "Papirus-Dark";
    cursor-theme = "Adwaita";
  };
}
