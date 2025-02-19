{
  mkUserConfigs =
    system: configPaths:
    args@{ lib, ... }:
    with lib;
    let
      # Function to import and merge configurations
      mergeConfigs =
        configs:
        let
          imported = map (path: (import path) (args)) configs;
        in
        {
          imports = concatLists (map (cfg: cfg.imports or [ ]) imported);
          home = foldl' (mergeAttrs) { } (map (cfg: cfg.home or { }) imported);
        };

      # Merged configuration
      mergedConfigs = mergeConfigs configPaths;
    in
    {
      imports = mergedConfigs.imports;
      home = mergedConfigs.home;
    };

}
