{ pkgs, ... }:
{
  home.packages = [
    pkgs.nixgl.nixGLNvidia
    pkgs.nixgl.nixVulkanNvidia
    pkgs.nixgl.auto.nixGLDefault
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
        echo "MISMATCH: update nvidiaVersion in ~/.config/home-manager/flake.nix"
        exit 1
      fi
    '')
  ];
}
