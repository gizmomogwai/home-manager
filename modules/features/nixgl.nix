{
  config,
  inputs,
  lib,
  ...
}: {
  options.nvidiaVersion = lib.mkOption {
    type = lib.types.str;
    default = "595.99.02";
    description = "Host nvidia driver version nixGL is pinned to (see check-nixgl-version).";
  };
  options.nvidiaHash = lib.mkOption {
    type = lib.types.str;
    # nix store prefetch-file https://download.nvidia.com/XFree86/Linux-x86_64/<version>/NVIDIA-Linux-x86_64-<version>.run
    default = "sha256-6HR3lYv3YwcFSTJL1a1slI66btIQ5EAFs+/4SUD24ew=";
    description = "Hash of the nvidia .run file (pure eval needs it). Update together with nvidiaVersion.";
  };

  config = {
    # lazy attr: only evaluated (and only buildable) on linux hosts that use it
    overlays = [
      (final: prev: {
        nixgl =
          import (prev.applyPatches {
            name = "nixGL-patched";
            src = inputs.nixgl;
            # upstream sets GBM_BACKENDS_PATH only for mesa; webkitgtk then loads mesa's dri_gbm.so
            patches = [../../nixgl-nvidia-gbm.patch];
          }) {
            pkgs = final;
            inherit (config) nvidiaVersion nvidiaHash;
          };
      })
    ];

    flake.modules.homeManager.nixgl-nvidia = {pkgs, ...}: {
      targets.genericLinux.nixGL.packages = pkgs.nixgl;
      targets.genericLinux.nixGL.defaultWrapper = "nvidia";
      home.packages = [
        pkgs.nixgl.nixGLNvidia
        pkgs.nixgl.nixVulkanNvidia
        # auto.nixGLDefault fetches the driver without hash (impure); same `nixGL` binary, pinned
        (pkgs.nixgl.nixGLCommon pkgs.nixgl.nixGLNvidia)
        (pkgs.runCommand "nixVulkan" {} ''
          mkdir -p $out/bin
          cp ${pkgs.nixgl.nixVulkanNvidia}/bin/nixVulkanNvidia-* $out/bin/nixVulkan
          chmod +x $out/bin/nixVulkan
        '')
        pkgs.vulkan-tools
        pkgs.mesa-demos

        (pkgs.writeShellScriptBin "check-nixgl-version" ''
          host_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null | head -1)
          # Binary is named nixGLNvidia-<version>, extract the version suffix
          nixgl_bin=$(ls ~/.nix-profile/bin/nixGLNvidia-* 2>/dev/null | head -1)
          pinned_version=$(echo "$nixgl_bin" | grep -oP '(?<=nixGLNvidia-)[0-9.]+' || echo "unknown")
          echo "Host Nvidia driver : $host_version"
          echo "NixGL pinned for   : $pinned_version"
          if [ "$host_version" = "$pinned_version" ]; then
            echo "OK: versions match"
          else
            echo "MISMATCH: update nvidiaVersion and nvidiaHash in ~/.config/home-manager/modules/features/nixgl.nix"
            exit 1
          fi
        '')
      ];
    };

    flake.modules.homeManager.nixgl-intel = {pkgs, ...}: {
      home.packages = [pkgs.nixgl.nixGLIntel];
    };
  };
}
