{ ... }:
let
  custom = {
    font = "FiraCode Nerd Font";
    font_size = "11px";
    font_weight = "bold";
    text_color = "#cdd6f4";
    secondary_accent = "89b4fa";
    tertiary_accent = "f5f5f5";
    background = "11111B";
    opacity = "0.98";
  };
in {
  programs.waybar.style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "FiraCode Nerd Font";
        font-size: 15px;
        min-height: 25px;
        padding: 0px 3px;
    		color: #fbf1c7;
    }

    .modules-left {
        padding-left: 6px;
        margin-top: 0px;
        margin-bottom: 0px;
    }

    .modules-right {
        padding-right: 6px;
        margin-top: 0px;
        margin-bottom: 0px;
    }

    #waybar {
        background: #3c3836;
    }

    #custom-separator {
        padding: 0px 0px;
        margin: 0px 5px;
    }

    /* Fix for Alexays/Waybar/issues/1741 */
    label:disabled, button:disabled {
        color: inherit;
        background-image: none;
    }



    #workspaces button {
        margin: 0px 0px;
        background: #3c3836;
        color: #cccccc;
        min-width: 20px;
        /*border-radius: 15px;*/
    }

    #workspaces button.focused {
        background: #504945;
    }

    #workspaces button:hover {
        background: #d5c4a1;
    }

    #mode {
        background: #64727D;
    }

    /* Groups and single items */

    #cpu, #memory {
        color: #b8bb26;
    }

    #disk.root, #disk.xpsroot, #disk.mirror {
        color: #b8bb26;
    }

    #network, #custom-pia-status {
        color: #d5c4a1;
    }

    #idle_inhibitor, #pulseaudio, #tray {
        color: #d5c4a1;
    }

    #workspaces {
        color: #504945;
    }

    #clock {
        color: #fbf1c7;
        font-size: 16px;
    }

    #custom-gamemode {
        background: #61d42c;
        color: black;
    }

    #custom-checkdots {
        color: #00c3ff;
    }

    #custom-checkupdate {
        color: #ffa600;
    }

    /* Right Side */
    #disk.mirror, #disk.xpsroot, #custom-pia-status, 
    #tray, #clock, #custom-checkdots, #custom-checkupdate, #workspaces, #custom-media, 
    #mode, #custom-gamemode, #memory, #memory.xps, #backlight {
    	margin-right: 5px;
    }

    /* Left Sides */

    #cpu, #disk.root, #disk.xpsroot, #network, #pulseaudio, #clock, #custom-checkdots, #custom-checkupdate,
    #workspaces, #custom-media, #mode, #custom-gamemode, #battery {
    	margin-left: 5px;
    }



    /* Other settings */

    #battery.warning {
    	color: #fabd2f;
    }

    #battery.critical {
    	color: #fb4934;
    }

    #disk.root.warning, #disk.mirror.warning {
        color: #fabd2f;
    }

    #disk.root.high, #disk.mirror.high {
        color: #fe8019;
    }

    #disk.root.critical, #disk.mirror.critical {
        color: #fb4934;
    }

    #temperature.critical {
        color: #fb4934;
    }

    @keyframes blink {
        to {
            background-color: #fbf1c7;
            color: #1d2021;
        }
    }

    /* Secondary monitor specific options*/
    /*window.DP-2 * {
        padding: 0;
    }

    window.DP-2 #window {
        padding: 0px;
    }

    window.DP-2 #workspaces {
        padding: 0px;
    }

    window.DP-2 #clock {
        background-color: transparent;
        color: #ffffff;
        padding: 0px;

        border-style: none;
    }

    window.DP-2 #workspaces {
        padding-left: 0px;
    }*/
  '';
  #   programs.waybar.style = ''
  # * {
  #   border: none;
  #   font-family: JetBrains Mono;
  #   font-weight: bold;
  #   font-size: 11px;
  #   min-height: 0;
  # }
  # 
  # tooltip {
  # 	background: #282828;
  # 	border: 0px solid;
  # 	border-radius: 0px;
  # }
  # 
  # window#waybar {
  #   background: #282828;
  #   color: #ebdbb2;
  # }
  # 
  # #workspaces button {
  #   padding: 0 0.6em;
  #   color: #a89984;
  #   background: #504945;
  #   border-radius: 0px;
  #   margin-right: 4px;
  #   margin-left: 4px;
  #   margin-top: 2px;
  #   margin-bottom: 2px;
  # }
  # 
  # #workspaces button.active {
  #   color: #ebdbb2;
  #   background: #665c54;
  # }
  # 
  # #workspaces button.urgent {
  #   color: #1d2021;
  #   background: #fb4934;
  # }
  # 
  # #workspaces button:hover {
  #   background: #665c54;
  # }
  # 
  # #battery,
  # #pulseaudio,
  # #temperature,
  # #cpu,
  # #disk,
  # #date,
  # #clock,
  # #network,
  # #bluetooth,
  # #workspaces,
  # #language,
  # #custom-spotify,
  # #custom-weather,
  # #custom-cputemp,
  # #custom-gputemp,
  # #custom-ram,
  # #memory,
  # #window,
  # #tray {
  #   color: #d5c4a1;
  #   background: #433e3c;
  #   padding: 0 0.6em;
  #   margin-right: 4px;
  #   margin-left: 2px;
  #   margin-top: 4px;
  #   margin-bottom: 4px;
  #   border-radius: 0px;
  # }
  # 
  # #battery {
  #   padding: 0 0.6em;
  #   margin-right: 4px;
  # }
  # 
  # #tray {
  #   padding: 0 0.6em;
  #   margin-right: 4px;
  # }
  # 
  # #custom-tray-icon {
  #   margin-left: 0px;
  # }
  #   '';
}
