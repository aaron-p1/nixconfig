{ ... }:
{
  security.pam.u2f = {
    enable = true;
    cue = true;
    authFile = "/etc/u2f-mappings";
    appId = "nixauth";
  };

  environment.etc."u2f-mappings" = {
    enable = true;
    text = "";
  };
}
