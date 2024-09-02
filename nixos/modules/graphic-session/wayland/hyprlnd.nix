{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  environment.sessionVariables = {
    # hint electron apps to use wayland:
    NIXOS_OZONE_WL = "1";
    
    # If your cursor becomes invisible
    WLR_NO_HARDWARE_CURSORS = "1";

    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
  };

  services.displayManager.defaultSession = "hyprland";
  services.displayManager.sddm.wayland.enable = true;
}
