{
  preservation = {
    enable = true;
    preserveAt."/persist" = {
      directories = [
        "/var/lib/thread"
        {
          directory = "/var/lib/hass";
          user = "hass";
          group = "hass";
        }
        {
          directory = "/var/lib/private/matterjs-server";
          user = "matterjs-server";
          group = "matterjs-server";
          mode = "0700";
        }
      ];
    };
  };
}
