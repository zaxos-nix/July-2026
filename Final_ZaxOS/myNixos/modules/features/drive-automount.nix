{ self, inputs, ... }: {
  flake.nixosModules.driveAutomount = { pkgs, ... }: {
    boot.supportedFilesystems = [ "ntfs" "exfat" ];

    environment.systemPackages = with pkgs; [
      ntfs3g
      exfatprogs
      dosfstools
      gptfdisk
      parted
    ];

    services.udisks2.enable = true;
    services.gvfs.enable = true; # trash://, mtp://, network mounts from file managers
    security.polkit.enable = true;

    # Without GNOME's automount daemon there, mounting/unmounting removable
    # media (including NTFS/exFAT USB sticks) would otherwise prompt for the
    # root password every time. This rule lets members of "wheel" (and
    # "storage", used below for izo/zax/izax) manage udisks2/UDisks2 drives
    # without authentication, while udiskie (per-user, see home/common.nix)
    # does the actual auto-mount-on-insert.
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.udisks2.filesystem-mount" ||
             action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
             action.id == "org.freedesktop.udisks2.filesystem-unmount-others" ||
             action.id == "org.freedesktop.udisks2.filesystem-fstab" ||
             action.id == "org.freedesktop.udisks2.eject-media") &&
            (subject.isInGroup("wheel") || subject.isInGroup("storage"))) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
