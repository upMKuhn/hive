{
  inputs,
  cell,
}: let
  inherit (inputs) nixos-generators;
  inherit (cell) nixosProfiles;
in {
  larva = {
    system = "x86_64-linux";
    packages = inputs.nixos.legacyPackages;
    deployment = {
      targetHost = "fe80::47";
      targetPort = 22;
      targetUser = "root";
      allowLocalDeployment = false;
      buildOnTarget = false;
    };
    imports = [
      nixos-generators.nixosModules.install-iso
      nixosProfiles.bootstrap
    ];
  };
}