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
}
