{
  nixpkgs,
  refs,
  system ? builtins.currentSystem,
  ...
}:
let
  pkgs = import nixpkgs { inherit system; };
  inherit (pkgs) lib;

  branches = builtins.fromJSON (builtins.readFile refs);

  mkBuildJob = name: {
    schedulingshares = 100;
    description = "Build config branch ${name}";
    checkinterval = "600";
    enabled = "1";
    enableemail = false;
    emailoverride = "";
    keepnr = 1;
    hidden = false;
    type = 0;
    nixexprinput = "src";
    nixexprpath = "hydra/release.nix";
    inputs.src = {
      emailresponsible = false;
      type = "git";
      value = "http://github.com/shawn8901/test ${name}";
    };
  };
  desc = lib.mapAttrs (branch: info: mkBuildJob branch) branches;
  log = {
    branches = branches;
    jobsets = desc;
  };

in
{
  jobsets = pkgs.runCommand "spec-jobsets.json" { } ''
    cat >$out <<EOF
    ${builtins.toJSON desc}
    EOF
    # This is to get nice .jobsets build logs on Hydra
    cat >tmp <<EOF
    ${builtins.toJSON log}
    EOF
    ${pkgs.jq}/bin/jq . tmp
  '';
}
