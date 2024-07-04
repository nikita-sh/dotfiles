{ ... }: {
  wayland.windowManager.hyprland = {
    extraConfig = ''
      $mainMod = SUPER
      
      # monitor=,preferred,auto,1
      # monitor=,preferred,0x0,1
      monitor=eDP-1,3840x2400,0x0,2
      monitor=,preferred,auto,1

      # autostart
      exec-once = systemctl --user import-environment &
      exec-once = hash dbus-update-activation-environment 2>/dev/null &
      exec-once = dbus-update-activation-environment --systemd &
      exec-once = nm-applet &
      exec-once = wl-paste --primary --watch wl-copy --primary --clear
      # exec-once = swaybg -m fill -i ~/dev/nixos-config/wallpapers/city.jpg &
      exec-once = sleep 1 && swaylock
      exec-once = hyprctl setcursor Nordzy-cursors 22 &
      exec-once = waybar &
      exec-once = mako &
      exec-once = /home/nikita/dev/nixos-config/wallpapers/cycle_wallpaper.sh 1800 &
      exec-once = calcurse --daemon

      xwayland {
        force_zero_scaling = false
      }

      input {
          kb_layout = us
          kb_options = grp:win_space_toggle
          follow_mouse = 1
          repeat_rate = 30
          repeat_delay = 300
      }

      general {
        gaps_in = 5
        gaps_out = 10
        border_size = 2
      	col.active_border = rgb(85796f)
        col.inactive_border = rgb(504742)
      	no_cursor_warps = true
      	resize_on_border = false
        layout = dwindle
      	allow_tearing = true
      }

      decoration {
          rounding = 0
          blur {
      		enabled = false
              size = 10
              passes = 3
      		ignore_opacity = true
          }
          drop_shadow = yes
          shadow_range = 17
      	shadow_scale = 0.98
      	shadow_offset = 5 3
          shadow_render_power = 1
      	shadow_ignore_window = true
      	col.shadow = rgb(313131)

      	dim_inactive = true
      	dim_strength = 0.10
      	dim_special = 0.3

      }

      animations { 
      	enabled = no
      	bezier = workspace,0.17, 1.17, 0.3,1
      	bezier = windowin,0.15,1.15,0.95,1
      	bezier = windowmove,0.7, 0.7, 0.1,1.05
          animation = windows, 1, 3, default, popin
          animation = windowsIn, 1, 3.2, windowin, popin 95%
          animation = windowsOut, 1, 4, default, popin 96%
          animation = windowsMove, 1, 4, windowmove, slide
          animation = workspaces, 1, 5, workspace, slidefadevert 8%
      	animation = specialWorkspace, 1, 5, workspace, slidefadevert 10%
      	# first_launch_animation = true
      }


      binds {
          allow_workspace_cycles = true
      }

      misc {
        disable_hyprland_logo = true
        animate_manual_resizes = true
        disable_autoreload = false 
      	enable_swallow = true
      	animate_mouse_windowdragging = true
      	layers_hog_keyboard_focus = true
      	no_direct_scanout = true
      	vrr = 0
      }

      # ----------------------------------------------------------------

      # show keybinds list
      bind = $mainMod, F1, exec, show-keybinds

      # keybindings
      bind = $mainMod, Return, exec, kitty
      bind = ALT, Return, exec, kitty --title float_kitty
      bind = $mainMod SHIFT, Return, exec, kitty --start-as=fullscreen -o 'font_size=16'
      bind = $mainMod, Q, killactive,
      bind = $mainMod, F, fullscreen, 0
      bind = $mainMod SHIFT, F, fullscreen, 1
      bind = $mainMod, Space, togglefloating,
      bind = $mainMod, D, exec, pkill wofi || wofi --show drun --normal-window
      bind = $mainMod SHIFT, S, exec, hyprctl dispatch exec '[workspace 5 silent] SoundWireServer'
      bind = $mainMod, Escape, exec, swaylock
      bind = $mainMod SHIFT, Escape, exec, shutdown-script
      bind = $mainMod, P, pseudo,
      bind = $mainMod, J, togglesplit,
      bind = $mainMod, E, exec, nemo
      bind = $mainMod ALT, B, exec, pkill -SIGUSR1 .waybar-wrapped
      bind = $mainMod, C ,exec, hyprpicker -a
      bind = $mainMod, G,exec, $HOME/.local/bin/toggle_layout
      bind = $mainMod, W,exec, pkill wofi || wallpaper-picker
      bind = $mainMod SHIFT, W, exec, vm-start
      bind =,XF86MonBrightnessDown,exec,brightnessctl set 10%-
      bind =,XF86MonBrightnessUp,exec,brightnessctl set +10%
      bind =,XF86Messenger,exec,playerctl previous
      bind =,XF86Go,exec,playerctl play-pause
      bind =,Cancel,exec,playerctl next
      # bind = $mainMod ALT, S, exec, grimshot copy window
      bind = $mainMod SHIFT, C, exec, pkill cycle_wallpaper && ~/dev/nixos-config/wallpapers/cycle_wallpaper.sh 1800 &
      
      # program binds
      bind = $mainMod SHIFT, V, exec, ELECTRON_OZONE_PLATFORM_HINT=wayland hyprctl dispatch exec '[workspace 2 silent] code /home/nikita/dev --enable-features=UseOzonePlatform --ozone-platform=wayland'
      bind = $mainMod SHIFT, B, exec, hyprctl dispatch exec '[workspace 3 silent] firefox'
      bind = $mainMod SHIFT, S, exec, ELECTRON_OZONE_PLATFORM_HINT=wayland hyprctl dispatch exec '[workspace 4 silent]' slack
      bind = $mainMod SHIFT, O, exec, ELECTRON_OZONE_PLATFORM_HINT=wayland hyprctl dispatch exec '[workspace 5 silent] obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland'
      bind = $mainMod SHIFT, M, exec, ELECTRON_OZONE_PLATFORM_HINT=wayland hyprctl dispatch exec '[workspace 6 silent] spotify --enable-features=UseOzonePlatform --ozone-platform=wayland'
      bind = $mainMod SHIFT, D, exec, hyprctl dispatch exec '[workspace 7 silent] discord --enable-features=UseOzonePlatform --ozone-platform=wayland'

      # screenshot
      bind = $mainMod, Print, exec, grimblast --notify --cursor save area ~/Pictures/$(date +'%Y-%m-%d-At-%Ih%Mm%Ss').png
      bind = ,Print, exec, grimblast --notify --cursor  copy area

      # switch focus
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d

      # switch workspace
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # same as above, but switch to the workspace
      bind = $mainMod SHIFT, 1, movetoworkspacesilent, 1     # movetoworkspacesilent
      bind = $mainMod SHIFT, 2, movetoworkspacesilent, 2
      bind = $mainMod SHIFT, 3, movetoworkspacesilent, 3
      bind = $mainMod SHIFT, 4, movetoworkspacesilent, 4
      bind = $mainMod SHIFT, 5, movetoworkspacesilent, 5
      bind = $mainMod SHIFT, 6, movetoworkspacesilent, 6
      bind = $mainMod SHIFT, 7, movetoworkspacesilent, 7
      bind = $mainMod SHIFT, 8, movetoworkspacesilent, 8
      bind = $mainMod SHIFT, 9, movetoworkspacesilent, 9
      bind = $mainMod SHIFT, 0, movetoworkspacesilent, 10
      bind = $mainMod CTRL, c, movetoworkspace, empty

      # window control
      bind = $mainMod SHIFT, left, movewindow, l
      bind = $mainMod SHIFT, right, movewindow, r
      bind = $mainMod SHIFT, up, movewindow, u
      bind = $mainMod SHIFT, down, movewindow, d
      bind = $mainMod CTRL, left, resizeactive, -80 0
      bind = $mainMod CTRL, right, resizeactive, 80 0
      bind = $mainMod CTRL, up, resizeactive, 0 -80
      bind = $mainMod CTRL, down, resizeactive, 0 80
      bind = $mainMod ALT, left, moveactive,  -80 0
      bind = $mainMod ALT, right, moveactive, 80 0
      bind = $mainMod ALT, up, moveactive, 0 -80
      bind = $mainMod ALT, down, moveactive, 0 80

      # media and volume controls
      bind = ,XF86AudioRaiseVolume,exec, pamixer -i 2
      bind = ,XF86AudioLowerVolume,exec, pamixer -d 2
      bind = ,XF86AudioMute,exec, pamixer -t
      bind = ,XF86AudioPlay,exec, playerctl play-pause
      bind = ,XF86AudioNext,exec, playerctl next
      bind = ,XF86AudioPrev,exec, playerctl previous
      bind = , XF86AudioStop, exec, playerctl stop
      bind = $mainMod, mouse_down, workspace, e-1
      bind = $mainMod, mouse_up, workspace, e+1

      # mouse binding
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

      # windowrule
      windowrule = float,audacious
      windowrule = workspace 8 silent, audacious
      windowrule = pin,wofi
      windowrule = float,wofi
      windowrule = noborder,wofi
      windowrule = tile, neovide
      windowrule = idleinhibit focus,mpv
      windowrule = float,udiskie
      windowrule = float,title:^(Transmission)$
      windowrule = float,title:^(Volume Control)$
      windowrule = float,title:^(Firefox — Sharing Indicator)$
      windowrule = move 0 0,title:^(Firefox — Sharing Indicator)$
      windowrule = size 700 450,title:^(Volume Control)$
      windowrule = move 40 55%,title:^(Volume Control)$
      windowrulev2 = float, title:^(Picture-in-Picture)$
      windowrulev2 = opacity 1.0 override 1.0 override, title:^(Picture-in-Picture)$
      # windowrulev2 = opacity 1.0 override 1.0 override, title:^(.*YouTube.*)$
      windowrulev2 = pin, title:^(Picture-in-Picture)$
      windowrule = float,imv
      windowrule = center,imv
      windowrule = size 1200 725,imv
      windowrulev2 = opacity 1.0 override 1.0 override, title:^(.*imv.*)$
      windowrule = float,mpv
      windowrule = center,mpv
      windowrulev2 = opacity 1.0 override 1.0 override, title:^(.*mpv.*)$
      windowrule = tile,Aseprite
      windowrulev2 = opacity 1.0 override 1.0 override, class:(Aseprite)
      windowrulev2 = opacity 1.0 override 1.0 override, class:(Unity)
      windowrule = size 1200 725,mpv
      windowrulev2 = idleinhibit focus, class:^(mpv)$
      windowrulev2 = idleinhibit fullscreen, class:^(firefox)$
      windowrulev2 = float,class:^(blueman-manager)$

      windowrule = float,title:^(float_kitty)$
      windowrule = center,title:^(float_kitty)$
      windowrule = size 950 600,title:^(float_kitty)$

      windowrulev2 = float,class:^(pavucontrol)$
      windowrulev2 = float,class:^(SoundWireServer)$
      windowrulev2 = float,class:^(file_progress)$
      windowrulev2 = float,class:^(confirm)$
      windowrulev2 = float,class:^(dialog)$
      windowrulev2 = float,class:^(download)$
      windowrulev2 = float,class:^(notification)$
      windowrulev2 = float,class:^(error)$
      windowrulev2 = float,class:^(confirmreset)$
      windowrulev2 = float,title:^(Open File)$
      windowrulev2 = float,title:^(branchdialog)$
      windowrulev2 = float,title:^(Confirm to replace files)$
      windowrulev2 = float,title:^(File Operation Progress)$

      windowrule = float,Calendar
    '';
  };
}
