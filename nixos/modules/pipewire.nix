{ ... }:
{
  security.rtkit.enable = true; # optional but recommended

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    #jack.enable = true; # for jack applications

    media-session.enable = true;
  };
}
