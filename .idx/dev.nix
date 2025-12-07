# To learn more about how to use Nix to configure your environment
# see: https://firebase.google.com/docs/studio/customize-workspace
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.jdk21,
    pkgs.unzip,
    pkgs.flutterfire-cli,
    pkgs.nodejs # Provides npm for installing Firebase CLI
  ];
  # Sets environment variables in the workspace
  env = {};
  idx = {
    workspace = {
      # Runs when a workspace is first created with this `dev.nix` file
      onCreate = { },
      # To run something each time the workspace is (re)started, use the `onStart` hook
    };
    # Enable previews and customize configuration
    previews = {
      enable = true;
      previews = {
        web = {
          command = ["flutter", "run", "--machine", "-d", "web-server", "--web-hostname", "0.0.0.0", "--web-port", "$PORT"];
          manager = "flutter";
        };
        android = {
          command = ["flutter", "run", "--machine", "-d", "android", "-d", "localhost:5555"];
          manager = "flutter";
        };
      };
    };
  };
}
