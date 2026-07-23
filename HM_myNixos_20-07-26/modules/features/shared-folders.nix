{ self, inputs, ... }: {
  flake.nixosModules.sharedFolders = { lib, ... }: {
    users.groups.shared = { };

    # 2775: setgid so new files/dirs inherit the "shared" group, rwx for
    # group so any member can read/write, sticky-free (unlike /tmp) since
    # these are collaborative folders, not drop-boxes.
    systemd.tmpfiles.rules =
      [ "d /home/Shared 2775 root shared - -" ]
      ++ map
        (dir: "d /home/Shared/${dir} 2775 root shared - -")
        [ "Desktop" "Documents" "Downloads" "Music" "Pictures" "Videos" "Public" "Templates" ]
      # Wallpaper pool shared by noctalia (izo) and DMS (zax/izax) — see
      # modules/features/noctalia.json and home/{zax,izax}.nix.
      ++ [ "d /home/Shared/Pictures/Wallpapers 2775 root shared - -" ];
  };
}
