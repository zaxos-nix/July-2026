# izax — mangowc + Dank Material Shell (DMS)
{ pkgs, lib, self, inputs, ... }: {
  imports = [
    ./common.nix
    inputs.mango.hmModules.mango
    inputs.dms.homeModules.dank-material-shell
  ];

  home.username = "izax";
  home.homeDirectory = "/home/izax";

  home.packages = with pkgs; [
    foot
    brave
    nautilus
  ];

  # DMS's README lists MangoWC as an officially supported compositor and
  # runs itself as a systemd --user service, so no manual spawn is needed
  # here either — same as zax's niri setup.
  programs.dank-material-shell = {
    enable = true;

    # NOTE: verify this key path against the pinned DMS revision — same
    # shared wallpaper pool as izo (noctalia) and zax (DMS on niri), so all
    # three users rotate through the same images.
    settings.wallpaper = {
      path = "/home/Shared/Pictures/Wallpapers";
      mode = "random";
      cyclingEnabled = true;
      cyclingInterval = 300; # seconds
    };
  };

  # ── Keybinds, harmonized with izo's/zax's niri config ──
  # mango uses its own `config.conf` action-name dialect (not KDL), confirmed
  # against mangowm/mango's own config.conf and tag-workspace docs:
  #   niri action              → mango action
  #   close-window             → killclient
  #   maximize-column          → togglemaximizescreen
  #   fullscreen-window        → togglefullscreen
  #   focus-column/window-*    → focusdir,<left|right|up|down>
  #   move-column-*            → exchange_client,<left|right>
  #   switch-preset-col-width  → switch_proportion_preset
  #   toggle-overview          → toggleoverview
  #   focus-workspace N        → view,N,0        (NOTE: unverified action name)
  #   move-column-to-ws N      → tagsilent,N,0   (confirmed: moves w/o switching view)
  # There's no mango equivalent for niri's show-hotkey-overlay bind.
  #
  # NOTE: mango's config format is its own `config.conf`/`autostart.sh`
  # dialect, passed through as raw text below. Check `inputs.mango`
  # (mangowm/mango) docs for the current option reference before
  # relying on these values verbatim.
  wayland.windowManager.mango = {
    enable = true;

    settings = ''
      # --- Layout ---
      gappih=4
      gappiv=4
      gappoh=4
      gappov=4
      borderpx=2

      # --- Input ---
      tap_to_click=1
      mouse_natural_scrolling=0

      # --- Core launchers ---
      bind=SUPER,Return,spawn,${lib.getExe pkgs.ghostty}
      bind=SUPER,N,spawn,${lib.getExe pkgs.nautilus}
      bind=SUPER,B,spawn,${lib.getExe pkgs.brave}
      bind=SUPER,T,spawn,${lib.getExe pkgs.foot}
      bind=SUPER,M,spawn,${lib.getExe pkgs.ghostty} -e ${lib.getExe pkgs.yazi}
      bind=SUPER,Space,spawn,dms ipc call spotlight toggle
      bind=SUPER,O,toggleoverview,

      # --- Window & layout control ---
      bind=SUPER,Q,killclient,
      bind=SUPER,R,switch_proportion_preset,
      bind=SUPER,F,togglemaximizescreen,
      bind=SUPER+SHIFT,F,togglefullscreen,

      # --- Focus navigation ---
      bind=SUPER,Left,focusdir,left
      bind=SUPER,Right,focusdir,right
      bind=SUPER,Down,focusdir,down
      bind=SUPER,Up,focusdir,up

      # --- Moving windows ---
      bind=SUPER+CTRL,Left,exchange_client,left
      bind=SUPER+CTRL,Right,exchange_client,right

      # --- Workspace (tag) navigation ---
      bind=SUPER,1,view,1,0
      bind=SUPER,2,view,2,0
      bind=SUPER,3,view,3,0

      # --- Move window to workspace (tag), without following ---
      bind=SUPER+SHIFT,1,tagsilent,1,0
      bind=SUPER+SHIFT,2,tagsilent,2,0
      bind=SUPER+SHIFT,3,tagsilent,3,0

      # --- System ---
      bind=SUPER+SHIFT,E,quit,
    '';

    autostart_sh = ''
      # DMS is launched by its own systemd user service; nothing else
      # required to start here for a minimal session.
    '';
  };
}
