{ ... }: {
  programs.waybar.settings.mainBar = {
    layer = "top";
    position = "top";
    #height = 30;
    # modules-left = ["hyprland/workspaces" "custom/music"];
    # modules-center = ["hyprland/window"];
    # modules-right = ["idle_inhibitor" "pulseaudio" "network" "cpu" "memory" "battery" "tray" "clock"];
    height = 20;
    modules-left = [
      "hyprland/workspaces"
      "custom/media"
      "idle_inhibitor"
      "hyprland/window"
    ];
    modules-right = [
      "disk#root"
      "cpu"
      "memory"
      "network"
      "battery"
      "clock"
      "pulseaudio"
      "tray"
    ];
    "hyprland/workspaces" = {
      disable-scroll = true;
      all-outputs = true;
      format = "{icon}";
      format-icons = {
        "1" = "I";
        "2" = "II";
        "3" = "III";
        "4" = "IV";
        "5" = "V";
        "6" = "VI";
        "7" = "VII";
        "8" = "VIII";
        "9" = "IX";
        "10" = "X";
      };
    };
    battery = {
      states = {
        # "good" = 95;
        warning = 30;
        critical = 15;
      };
      format = "{capacity}% ";
      format-charging = "{capacity}% 󱐋 ";
      format-plugged = "{capacity}%  ";
      format-alt = "{time} {icon}";
      # "format-good" = "", // An empty format will hide the module
      # "format-full" = "";
      format-icons = [ "" "" "" "" "" ];
    };

    "disk#root" = {
      interval = 30;
      format = "  {percentage_free}%";
      path = "/";
      states = {
        "warning" = 80;
        "high" = 90;
        "critical" = 95;
      };
    };

    "clock" = {
      tooltip-format = ''
        <big>{:%Y %B}</big>
        <tt><small>{calendar}</small></tt>'';
      format = "{:%I:%M %p}";
      format-alt = "{:%Y-%m-%d}";
      on-right-click = "gnome-calendar";
    };

    "idle_inhibitor" = {
      format = "{icon}";
      format-icons = {
        "activated" = " ";
        "deactivated" = " ";
      };
    };

    "tray" = {
      # icon-size = 12;
      icon-size = 18;
      spacing = 3;
    };

    "cpu" = {
      format = " {usage}%";
      tooltip = true;
      interval = 3;
    };

    "memory" = {
      format = "󰟜 {used:0.1f}G ({percentage}%)";
      interval = 3;
    };

    "backlight" = {
      device = "intel_backlight";
      format = "{icon} {percent}%";
      format-icons = [ "" ];
    };

    network = {
      interval = 1;
      tooltip = false;
      format-wifi =
        "<span foreground='#d79921'>{icon}</span>Connected<span foreground='#d79921'>  </span>{bandwidthUpBytes}<span foreground='#d79921'>  </span>{bandwidthDownBytes} ";
      format-disconnected = "󰤭";
      format-ethernet =
        "<span foreground='#d79921'>󰈀   </span>Wired  <span foreground='#d79921'>   </span>{bandwidthUpBytes}  <span foreground='#d79921'>   </span>{bandwidthDownBytes}";
      on-click-right-release =
        "alacritty --class nmtui -T 'Network Settings' -e nmtui";
      on-click-release =
        "$HOME/dev/nixos-config/modules/home/waybar/scripts/net.sh";
      format-icons = [ "󰤯 " "󰤟 " "󰤢 " "󰤥 " "󰤨 " ];
    };
    # "network" = {
    #   format-wifi = " ";
    #   format-ethernet = "  {bandwidthDownBits}";
    #   format-linked = " {ifname} (No IP)";
    #   format-disconnected = "Disconnected ⚠";
    #   format-alt = "{ifname} = {ipaddr}/{cidr}   {bandwidthDownBits}  {bandwidthUpBits}";
    #   tooltip-format-wifi = "SSID = {essid}\nAddress = {ipaddr}\nBand {frequency} MHz\nUp = {bandwidthUpBits}\nDown = {bandwidthDownBits}\nStrength = {signalStrength}%";
    #   interval = 2;
    #   # on-click-right = "${commands.terminal} -e nmtui";
    # };

    # "pulseaudio" = {
    #   # "scroll-step": 1, // %, can be a float
    #   format = "{icon} {volume}%";
    #   format-bluetooth = "{icon} {volume}% {format_source} ";
    #   format-bluetooth-muted = "婢 {icon} {format_source}";
    #   format-muted = "婢";
    #   format-source = " {volume}%";
    #   format-source-muted = "";
    #   format-icons = {
    #       "headphone" = "";
    #       "hands-free" = "";
    #       "headset" = "";
    #       "phone" = "";
    #       "portable" = "";
    #       "car" = "";
    #       "default" = ["奄" "奔" "墳"];
    #   };
    #   on-click = "pavucontrol";
    # };

    "custom/media" = {
      format = "{icon} {}";
      return-type = "json";
      max-length = 60;
      format-icons = {
        "spotify" = "";
        "default" = " ";
        "firefox" = "";
      };
      escape = true;
      #on-click = "${pkgs.playerctl}/bin/playerctl play-pause";
      #exec = "${mediaplayerCmd} 2> /dev/null";
    };

    # idle_inhibitor = {
    #     format = "{icon}";
    #     format-icons = {
    #       activated = "";
    #       deactivated = "";
    #     };
    # };

    # tray = {
    #     icon-size = 14;
    #     spacing = 10;
    # };

    # clock = {
    #     # Human Friendly
    #     format = "{:%A, %B %d at %I:%M %p}";
    #     # 24hr Robot Friendly
    #     format-alt = "{:%Y-%m-%d - %H:%M}";
    # };

    # cpu = {
    #   format = "{usage}% ";
    #   format-alt = "{avg_frequency}% ";
    #   interval = 2;  
    # };

    # memory = {
    #     interval = 30;
    #     format = "{used:0.1f}/{total:0.1f}G ";
    # };

    # network = {
    #     # "interface" = "wlp2s0", // (Optional) To force the use of this interface
    #     format-wifi = "{essid} ({signalStrength}%) ";
    #     format-ethernet = "{ifname} = {ipaddr} ";
    #     format-disconnected = "Disconnected ⚠";
    # };

    pulseaudio = {
      # "scroll-step" = 1;
      format = "{volume}% {icon} ";
      format-bluetooth = "{volume}% {icon}  ";
      format-muted = "";
      format-icons = {
        headphones = "";
        handsfree = "";
        headset = "";
        phone = "";
        portable = "";
        car = "";
        default = [ "" "" ];
      };
      on-click = "pavucontrol";
    };

    # "custom/music" = {
    #   format = "  {}";
    #   max-length = 60;
    #   interval = 5; # Remove this if your script is endless and write in loop
    #   exec = "$HOME/dev/nixos-config/modules/home/waybar/mediaplayer.sh 2> /dev/null"; # Script in resources folder
    #   tooltip = false;
    #   on-click = "playerctl play-pause";
    #   on-scroll-up = "playerctl previous";
    #   on-scroll-down = "playerctl next";
    # };
  };
  # programs.waybar.settings.mainBar = {
  #   layer = "top";
  #   position = "top";
  #   height = 24;

  #   modules-left = [
  #     "disk"
  #     "temperature"
  #     # "custom/ram"
  #     "memory"
  #     # "custom/cputemp"
  #     "cpu"
  #     # "custom/gputemp"
  #     "custom/spotify"
  #   ];
  #   modules-center = [ "hyprland/workspaces" ];
  #   modules-right =  [
  #     "pulseaudio"
  #     "custom/weather"
  #     "bluetooth"
  #     "network"
  #     "hyprland/language"
  #     "clock#time"
  #     "battery"
  #     "tray"
  #   ];

  #   "custom/cputemp" = {
  #     exec = "$HOME/.local/bin/binaries/cpu-temp";
  #     on-click-release = "bash $HOME/dev/nixos-config/modules/home/waybar/scripts/cpu.sh";
  #     format = "<span foreground='#d79921'>  </span>{}°C";
  #     tooltip = false;
  #   };

  #   "custom/gputemp" = {
  #     exec = "$HOME/.local/bin/binaries/gpu-temp";
  #     on-click-release = "bash $HOME/dev/nixos-config/modules/home/waybar/scripts/gpu.sh";
  #     format = "<span foreground='#d79921'>  </span>{}°C"; # The monitor glyph was selected because the GPU glyph is not rendered correctly. At least for me
  #     tooltip = false;
  #   };

  #   "custom/spotify" = {
  #     exec = "$HOME/dev/nixos-config/modules/home/waybar/scripts/spotify.py --player spotify";
  #     format = "<span size='10000' foreground='#98971a'> </span>{}";
  #     return-type = "json";
  #     on-click = "playerctl -p spotify play-pause";
  #     on-scroll-up = "playerctl -p spotify next";
  #     on-scroll-down = "playerctl -p spotify previous";
  #     tooltip = false;
  #   };

  #   "hyprland/language" = {
  #     format = "<span size='9000' foreground='#d79921'>  </span>{}";
  #     format-en = "ENG";
  #     format-ru = "another lang";
  #     tooltip = false;
  #     on-click-release = "hyprctl switchxkblayout sonix-usb-device next"; # replace sonix-usb-device to yours keyboard. Use `hyprctl devices`
  #   };

  #   disk = {
  #     interval = 60;
  #     format = "<span foreground='#d79921'>   </span>{used}";
  #     tooltip = false;
  #   };

  #   "custom/ram" = {
  #     exec = "$HOME/dev/nixos-config/modules/home/waybar/scripts/ram";
  #     format = "<span foreground='#d79921'>   </span>{} MB";
  #     tooltip = false;
  #   };

  #   "hyprland/workspaces" = {
  #     format = "{icon}";
  #     on-click-release = "activate";
  #     sort-by-numbers = false;
  #     on-scroll-up = "hyprctl dispatch workspace e+1";
  #     on-scroll-down = "hyprctl dispatch workspace e-1";
  #     format-icons = {
  #   	  "1" = "I";
  #   	  "2" = "II";
  #   	  "3" = "III";
  #   	  "4" = "IV";
  #   	  "5" = "V";
  #   	  "6" = "VI";
  #   	  "7" = "VII";
  #   	  "8" = "VIII";
  #   	  "9" = "IX";
  #   	  "10" = "X";
  #     };
  #   };

  #   tray = {
  #     icon-size = 14;
  #     spacing = 10;
  #     show-passive-items = true;
  #   };

  #   "clock#time" = {
  #     interval = 1;
  #     format = "<span foreground='#d79921' size='10000'> </span>{:%I:%M %p} ";
  #     tooltip = false;
  #     on-click-release = "bash $HOME/dev/nixos-config/modules/home/waybar/scripts/date.sh";
  #   };

  #   network = {
  #     interval = 1;
  #     tooltip = false;
  #     format-wifi = "<span foreground='#d79921'>{icon}  </span>Connected<span foreground='#d79921'>      </span>{bandwidthUpBytes}<span foreground='#d79921'>     </span>{bandwidthDownBytes} ";
  #     format-disconnected = "";
  #     format-ethernet = "<span foreground='#d79921'>   </span>Wired  <span foreground='#d79921'>   </span>{bandwidthUpBytes}  <span foreground='#d79921'>   </span>{bandwidthDownBytes}";
  #     on-click-right-release = "alacritty --class nmtui -T 'Network Settings' -e nmtui";
  #     on-click-release = "$HOME/dev/nixos-config/modules/home/waybar/scripts/net.sh";
  #     format-icons = [
  #     	"󰤯 "
  #     	"󰤟 "
  #     	"󰤢 "
  #     	"󰤥 "
  #     	"󰤨 "
  #     ];
  #   }; 

  #   bluetooth = {
  #     format = "";
  #     tooltip = false;
  #     format-disabled = "";
  #     format-connected = "<span foreground='#d79921' size='10000'> </span>{device_alias}";
  #     on-click-release = "blueman-manager";
  #   };

  #   "custom/weather" = {
  #     format = "{}";
  #     tooltip = true;
  #     interval = 3600;
  #     exec = "$HOME/dev/nixos-config/modules/home/waybar/scripts/weather.py";
  #     return-type = "json";
  #   };

  #   pulseaudio= {
  #       format= "{icon} {volume}%";
  #       format-muted= "󰖁 ";
  #       format-icons= {
  #           default= [" "];
  #       };
  #       scroll-step= 5;
  #       on-click= "pamixer -t";
  #   };
  #    memory= {
  #       format= "󰟜 {}%";
  #       format-alt= "󰟜 {used} GiB"; # 
  #       interval= 2;
  #   };
  #   cpu= {
  #       format= "  {usage}%";
  #       format-alt= "  {avg_frequency} GHz";
  #       interval= 2;
  #   };
  #   battery = {
  #       states = {
  #           # "good" = 95;
  #           warning = 30;
  #           critical = 15;
  #       };
  #       format = "{capacity}% {icon}";
  #       format-charging = "{capacity}% ";
  #       format-plugged = "{capacity}% ";
  #       format-alt = "{time} {icon}";
  #       # "format-good" = "", // An empty format will hide the module
  #       # "format-full" = "";
  #       format-icons = ["" "" "" "" ""];
  #   };
  # };
}
