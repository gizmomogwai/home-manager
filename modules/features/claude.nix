{
  flake.modules.homeManager.claude = {pkgs, ...}: {
    # nix arecord (routes to pipewire) for /voice: the claude wrapper's LD_LIBRARY_PATH breaks /usr/bin/arecord
    # ALSA_PLUGIN_DIR: claude's nix alsa-lib can't find the pipewire plugin named by /etc/alsa/conf.d/50-pipewire.conf
    home.packages = [
      (pkgs.symlinkJoin {
        name = "claude-code";
        paths = [pkgs.claude-code];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = "wrapProgram $out/bin/claude --set-default ALSA_PLUGIN_DIR ${pkgs.pipewire}/lib/alsa-lib";
      })
      pkgs.alsa-utils
    ];

    home.file.".claude/CLAUDE.md".source = ./claude/CLAUDE.md;

    programs.agent-skills.targets.claude = {
      enable = true;
      structure = "link";
      dest = ".claude/skills";
    };
  };
}
