# myNixos: nested modules/ tree + DMS as a wrapped package

This restructures the previous flat-file delivery into the actual
`modules/features/` + `modules/hosts/my-machine/` layout, and rebuilds DMS
to match `niri.nix`'s pattern — a plain wrapped package that Niri spawns —
instead of the native `programs.dms-shell` NixOS module used before.

## Tree

```
myNixos/
├── flake.nix
├── flake.lock
├── modules/
│   ├── parts.nix
│   ├── features/
│   │   ├── niri.nix          flake.nixosModules.niri (enable) +
│   │   │                     perSystem.packages.myNiri (wrapped niri)
│   │   ├── dms.nix           perSystem.packages.myDms (wrapped DMS)
│   │   ├── dms-greeter.nix   services.displayManager.dms-greeter (login)
│   │   ├── fish.nix
│   │   └── starship.nix
│   └── hosts/my-machine/
│       ├── default.nix
│       ├── configuration.nix
│       ├── hardware-configuration.nix
│       └── hda-jack-retask.fw
```

## The one real wrinkle: no curated DMS wrapper exists

`niri.nix` uses `inputs.wrapper-modules.wrappers.niri.wrap { settings = {...}; }`
— a curated, pre-built wrapper module maintained upstream specifically for
niri. I checked the live `nix-wrapper-modules` repo directly
(`wrapperModules/n/` contains `niri` and `noctalia-shell`; `wrapperModules/d/`
has no subfolder at all) — **there is no equivalent curated wrapper for
DMS.** So `dms.nix` can't mirror `niri.nix`'s pattern exactly; it uses the
library's generic, lower-level API instead, straight from their own docs:

```nix
inputs.wrapper-modules.lib.evalPackage [
  { inherit pkgs; }
  ({ pkgs, wlib, ... }: {
    imports = [ wlib.modules.default ];
    package = pkgs.dms-shell;
    runtimePkgs = [ pkgs.matugen ];
  })
]
```

This is a real, documented code path (not something improvised) — but it's
a materially thinner wrap than niri's. niri's wrap bakes a full settings
tree into an immutable KDL file; this only controls PATH (`runtimePkgs`)
and env around the `dms` binary. DMS reads and writes its own
`settings.json`/matugen output at runtime, the same runtime-writable-config
problem that made a wrapper-modules wrap of *Noctalia* "a real pain" for
its own maintainers to build
([BirdeeHub/nix-wrapper-modules#337](https://github.com/BirdeeHub/nix-wrapper-modules/issues/337))
— DMS has the identical structural issue, arguably worse since it
explicitly ships a `dms setup`/`dms run` step that generates and later
edits its own config files.

Concretely, `runtimePkgs = [ pkgs.matugen ]` is there because dynamic/
wallpaper theming needs `matugen` on PATH and the plain `pkgs.dms-shell`
derivation doesn't bundle it — that's the one thing this wrap needs to do
for DMS to theme anything at all. Everything else (`dgop`, `glib`, `cava`,
`khal`, `wtype` — system monitoring, VPN widgets, audio visualizer,
calendar, clipboard-paste) is left off, in the file's own comments, for
you to add back individually if wanted.

## What this drops versus the native-module version

The native `programs.dms-shell` module (used in the previous version of
this repo) also set, as `mkDefault true`:
- `services.power-profiles-daemon.enable`
- `services.accounts-daemon.enable`
- `hardware.i2c.enable`
- `hardware.graphics.enable`

None of that happens automatically now that DMS is "just a package" again.
Most of these tend to already be on by default on real laptop hardware, but
if a widget that depends on one of them (battery/power-profile toggle,
i2c-backed brightness control) doesn't work after boot, that's the first
place to look — add the relevant option to `configuration.nix` directly.

## Everything else, unchanged from the previous version

- `dms-greeter.nix` is untouched — it's a separate, independent concern
  (pre-login, greetd-based, native nixpkgs module) from `dms.nix` (the
  post-login, niri-spawned shell package). They don't conflict.
- `fish.nix` and `starship.nix` are unchanged — no autologin handoff, since
  login is still owned end-to-end by `dms-greeter.nix`.
- `autologin.nix` and `noctalia.nix`/`noctalia.json` remain deleted.

## Assumption I made, worth flagging

Your requested tree only listed `niri.nix` and `dms.nix` under
`features/` — no `dms-greeter.nix`, `fish.nix`, or `starship.nix`. I read
that as you highlighting the two files you specifically want restructured
(the directory nesting + the DMS wrap), not as an instruction to remove
the greeter or shell config. I kept all three. Say the word if you
actually wanted the greeter gone too — dropping it would mean going back
to `autologin.nix` + a Niri-spawned DMS with nothing running before login,
which is a coherent alternative, just a different one than what's here.

## Still unverified — no `nix` binary in this sandbox

1. Whether `wlib.evalPackage` / `wlib.modules.default` actually produces a
   working `dms` binary the way `pkgs.hello` does in the upstream docs
   example — that example is real and documented, but DMS is a much larger
   derivation than `hello` and I can't build-check it.
2. Whether `lib.getExe self'.packages.myDms` resolves correctly (needs
   `meta.mainProgram` to come through the wrap intact).
3. Everything already flagged as open in the previous `dms-greeter.nix`
   comments (compositor package resolution, matugen template generation
   timing) still applies.

Run `nix flake check` and `nixos-rebuild build` before trusting any of this
on the real machine.
