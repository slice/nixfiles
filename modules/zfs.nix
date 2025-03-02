{ ... }:

{
  services.zfs = {
    # default interval is one week
    autoScrub.enable = true;

    trim.enable = true;
  };
}
