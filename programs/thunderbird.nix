{ pkgs, config, persistentDir, ... }: {

  programs.thunderbird = {
    enable = true;

    profiles.me = {
      isDefault = true;
    };
  };


/*
  home.file.".thunderbird" = {
    force = true;
    source = config.lib.file.mkOutOfStoreSymlink "${persistentDir}/thunderbird";
  };
  */

}

