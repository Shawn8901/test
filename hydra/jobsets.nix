{
  nixpkgs,
  refs,
  pulls,
  system ? builtins.currentSystem,
  ...
}:
let
  pkgs = import nixpkgs { inherit system; };
  inherit (pkgs) lib;

  branches = builtins.fromJSON (builtins.readFile refs);
  pullRequests = builtins.fromJSON (builtins.readFile pulls);

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

  mkPrJob = name: info: {
    schedulingshares = 100;
    description = "Build PR ${name}";
    checkinterval = "600";
    enabled = "1";
    enableemail = false;
    emailoverride = "";
    keepnr = 1;
    hidden = false;
    type = 0;
    nixexprinput = "src";
    nixexprpath = "hydra/release.nix";
    inputs = {
      src = {
        emailresponsible = false;
        type = "git";
        value = "http://github.com/shawn8901/test ${info.head.sha}";
      };
      lockUpdate = {
        emailresponsible = false;
        type = "boolean";
        value = if lib.hasPrefix "update-" name then "true" else "false";
      };
    };
  };

  branchJobs = lib.mapAttrs (branch: info: mkBuildJob branch) (
    lib.filterAttrs (branch: v: (!lib.hasPrefix "update-" branch)) branches
  );
  prJobs = lib.mapAttrs' (
    branch: info: lib.nameValuePair ("PR: ${branch}") (mkPrJob branch info)
  ) pullRequests;
  desc = branchJobs // prJobs;
  log = {
    inputs = {
      prs = pullRequests;
      branches = branches;
    };
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
