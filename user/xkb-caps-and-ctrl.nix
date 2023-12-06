{ config, pkgs, ... }:

let

  xkbkeymap = ''
    xkb_keymap {
      xkb_keycodes  { include "evdev+aliases(qwerty)"	};
      xkb_types     { include "complete"	};
      xkb_compat    { include "complete"	};
      xkb_symbols   { include "pc+us+inet(evdev)+terminate(ctrl_alt_bksp)+rmm(caps_and_ctrl)"	};
      xkb_geometry  { include "pc(pc104)"	};
    };
  '';

  xkbsymbols = ''
    partial modifier_keys
    xkb_symbols "caps_and_ctrl" {
      replace key <CAPS> { [ Control_L ] };
      replace key <LCTL> { [ Escape ] };
      modifier_map Control { <CAPS> };
    };
  '';

  xkbcompCommand = ''
    #! /bin/sh
    ${pkgs.xorg.xkbcomp}/bin/xkbcomp -I${pkgs.writeTextDir "symbols/rmm" xkbsymbols} ${pkgs.writeText "xkbkeymap" xkbkeymap} $DISPLAY
  '';

in

{
  home.keyboard = null;
  systemd.user.services = {
    xkbcomp = {
      Unit = {
        Description = "Set up keyboard overrides";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.writeScript "xkbcomp-setup" xkbcompCommand}";
      };
    };
  };
}

