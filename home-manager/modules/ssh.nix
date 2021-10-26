{ ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      public-server = {
        hostname = "public-server";
        user = "aaron";
        port = 25566;
      };
      public-server-root = {
        hostname = "public-server";
        user = "root";
        port = 25566;
      };
    };
  };
}
