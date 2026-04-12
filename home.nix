{ config, pkgs, ... }:

{
  home.stateVersion = "24.11"; # Match your NixOS version
  
  # This makes the 'home-manager' command available in your terminal
  programs.home-manager.enable = true;

  # You can move your user-specific packages here later
  home.packages = [
    pkgs.htop 
    pkgs.go
    pkgs.git
    pkgs.wget
    pkgs.uxplay
    pkgs.kitty      # Hyprland's default terminal
    pkgs.nautilus   # A file manager for GNOME/Hyprland
    pkgs.wofi
    pkgs.polkit_gnome
    pkgs.brightnessctl
    pkgs.swayosd
    pkgs.wlsunset
    pkgs.bluetui
  ];

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true; # Keep this on for any remaining Xwayland apps
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  home.sessionVariables = {
    EDITOR = "nano";
    # Forces Electron apps (VS Code, Discord, Obsidian) to use Wayland
    NIXOS_OZONE_WL = "1"; 
    # Specifically tells Firefox to use Wayland
    MOZ_ENABLE_WAYLAND = "1";
  };

  services.swayosd.enable = true;

  services.wlsunset = {
    enable = true;
    latitude = "12.97";
    longitude = "77.59"; # Bangalore coordinates
    temperature = {
      day = 6500;
      night = 4000;
    };
  };

  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    settings = [
      {
        profile.name = "undocked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            mode = "1920x1080@60"; # Forces native res for that "huge" feel
            scale = 1.0;           # Prevents the "zoomed in" look
          }
        ];
      }
      {
        profile.name = "docked";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "*"; 
            status = "enable";
            scale = 1.0;
          }
        ];
      }
    ];
  };

  programs.waybar = {
      enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          height = 30;
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "hyprland/window" ];
          modules-right = [ "network" "cpu" "memory" "temperature" "battery" "clock" "tray" ];

          "network" = {
            format-wifi = "  {essid} ({signalStrength}%)";
            # This shows your Up/Down speeds
            format-ethernet = "󰈀  {ifname}  {bandwidthUpBits}  {bandwidthDownBits}";
            format-disconnected = "Disconnected ⚠";
            interval = 2; # Update every 2 seconds for speed accuracy
          };

          "cpu" = {
              format = "  {usage}%";
              tooltip = false;
          };

          "memory" = {
              format = "  {}%";
          };

          "battery" = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-plugged = "{capacity}% ";
            # These MUST be in an array [ ]
            format-icons = ["" "" "" "" ""];
          };

          "clock" = {
            format = "{:%I:%M %p | %a %d}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          };
        };
      };
    };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 0;
        hide_cursor = true;
        no_fade_in = true; # Disable animations
        no_fade_out = true;
        # Stop it from trying to auth an empty string
        ignore_empty_input = true;
      };

      # The "Rice" Background
      background = [
        {
          monitor = "";
          # Use the stock Hyprland wallpaper path or a screenshot
          path = "screenshot"; 
          # color = "rgba(25, 20, 20, 1.0)";
          blur_passes = 3; # This gives the nice glass effect
          blur_size = 8;
        }
      ];

      # The Clock Widget
      label = [
        {
          monitor = "";
          text = "$TIME";
          color = "rgba(200, 200, 200, 1.0)";
          font_size = 64;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 150";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
          shadow_size = 3;
          shadow_color = "rgba(0, 0, 0, 0.8)"; # Dark shadow
        }
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +'%d %B %Y, %A')\"";
          color = "rgba(200, 200, 200, 1.0)";
          font_size = 24;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 50"; # Moved down to avoid overlap
          halign = "center";
          valign = "center";
          shadow_passes = 2;
          shadow_size = 3;
          shadow_color = "rgba(0, 0, 0, 0.8)";
        }
      ];

      # The Input Field (Password box)
      input-field = [
        {
          monitor = "";
          size = "200, 50";
          outline_thickness = 3;
          dots_size = 0.33;
          dots_spacing = 0.15;
          dots_center = true;
          outer_color = "rgb(151515)";
          inner_color = "rgb(200, 200, 200)";
          font_color = "rgb(10, 10, 10)";
          fade_on_empty = false; # Keeps the field visible
          placeholder_text = "Password...";
          hide_input = false;
          
          # THE FIXES:
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>"; # Shows why it failed
          fail_transition = 300; # Faster reset after failure
          capslock_color = "rgb(255, 165, 0)";
        }
      ];
    };
  };

  programs.kitty = {
    enable = true;
    settings = {
      copy_on_select = "yes";
      background_opacity = "0.8"; # Adjust between 0.0 and 1.0
    };
  };

  # This will generate ~/.config/hypr/hyprland.conf for you
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      decoration = {
        rounding = 10;
        blur = {
          enabled = true; # Must be true for the window rule to work
          size = 8;
          passes = 2;
          new_optimizations = true; # Saves GPU by not re-rendering static blurs
          xray = true; # Further optimization
        };
      };

      # This ensures the blur effect ignores the window's own shadow/elements
      blurls = [ "kitty" ];

      bindle = [
        # Brightness Keys
        # Volume with OSD
        ", XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise"
        ", XF86AudioLowerVolume, exec, swayosd-client --output-volume lower"
        ", XF86AudioMute, exec, swayosd-client --output-volume mute-toggle"

        # Raw steps for maximum precision
        ", XF86MonBrightnessUp, exec, swayosd-client --brightness +1"
        # We run brightnessctl second to ensure it catches the '0' state and bumps it to 1
        ", XF86MonBrightnessDown, exec, swayosd-client --brightness -1; brightnessctl set 1+"
      ];

      input = {
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          scroll_factor = 0.5; # Optional: Adjust this if scrolling feels too fast
        };
      };
      workspace = [
        "1, monitor:desc:HDMI-A-1, default:true"
        "2, monitor:desc:HDMI-A-1"
        "3, monitor:desc:HDMI-A-1"
      ];

      animations = {
        enabled = false;
      };

      windowrulev2 = [
        "workspace 1, initialClass:^(kitty)$"
        "workspace 2, initialClass:^(Code)$"
        "workspace 2, title:^(.*Visual Studio Code.*)$" # Backup rule using title
        "workspace 3, initialClass:^(firefox)$"
        "opacity 0.8 0.8, class:^(kitty)$"
      ];

      # decoration = {
      #   rounding = 0;
      #   # THE FIX: shadows are now in their own block
      #   shadow = {
      #     enabled = false;
      #   };
      #   # blur = {
      #   #   enabled = false;
      #   # };
      # };

      misc = {
        # Drastically reduces CPU/GPU wakeups
        vfr = true; 
      };

      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "waybar"
        "swayosd-libinput-backend"
      ];
      "$mainMod" = "SUPER";
      bind = [
        "$mainMod, L, exec, hyprlock"
        "$mainMod, Q, exec, kitty"
        "$mainMod, R, exec, wofi --show drun"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, V, togglefloating,"
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod, F, fullscreen, 1"

        # Toggle Wi-Fi
        "$mainMod, W, exec, nmcli radio wifi $(nmcli radio wifi | grep -q 'enabled' && echo 'off' || echo 'on')"
        # Toggle Bluetooth
        "$mainMod, B, exec, bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on"

        # for testing
        "ALT, RETURN, exec, kitty"
        "ALT, ESCAPE, exit,"

        # Switch workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"

        # Move active window to workspace (Note the comma after SHIFT)
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"

        # Move windows
        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, d"
        
        # Mouse scroll workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];
      # Add your monitor setup (standard 1080p example)
      # MONITOR FIX: 
      # Disable laptop screen to force everything to your extended monitor
      # Replace 'eDP-1' with your actual laptop screen name if it differs
      # Correct syntax if you weren't using Kanshi:
      monitor = [
        "eDP-1, 1920x1080@60, 0x0, 1"
        ", preferred, auto, 1"
      ];
    };
  };

  # NEW: VS Code Configuration Module
  programs.vscode = {
    enable = true;
    package = (pkgs.vscode.override {
      commandLineArgs = [
        "--ozone-platform-hint=auto"
        "--ozone-platform=wayland"
        "--enable-features=WaylandWindowDecorations"
      ];
    }).overrideAttrs (oldAttrs: {
      # This ensures the desktop entry also uses the flags
      desktopItems = oldAttrs.desktopItems or [];
    });
    # This automatically installs the extensions for you
    extensions = with pkgs.vscode-extensions; [
      ms-python.python
      ms-vscode.cpptools
      golang.go
      bbenoist.nix
      dracula-theme.theme-dracula
    ];
    # You can also manage your settings.json here!
    userSettings = {
      "workbench.colorTheme" = "Quiet Light";
      #"editor.fontSize" = 14;
      #"nix.enableLanguageServer" = true;
      #"nix.serverPath" = "nil";
    };
  };

  # GNOME/Dconf settings moved here for cleaner user management
  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "close,minimize,maximize:";
    };
  };
}
