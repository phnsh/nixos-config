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
  ]; 

  # This will generate ~/.config/hypr/hyprland.conf for you
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, Q, exec, kitty"
        "$mod, R, exec, wofi --show drun" # You might need to add pkgs.wofi to home.packages
        "$mod, C, killactive,"
        "$mod, M, exit,"
        "$mod, V, togglefloating,"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
      ];
      # Add your monitor setup (standard 1080p example)
      monitor = ",preferred,auto,auto";
    };
  };

  # NEW: VS Code Configuration Module
  programs.vscode = {
    enable = true;
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