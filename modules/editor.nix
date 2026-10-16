{
  flake.modules.homeManager.editor = {pkgs, ...}: {
    home.packages = with pkgs; [
      (writeShellScriptBin "magit" ''
        ${emacs}/bin/emacs -nw --eval "(progn (if (locate-dominating-file default-directory \".jj\") (jj-log) (magit-status)) (delete-other-windows))"
      '')
      eask-cli # like cask for emacs
      emacs
      enchant
      hunspell
      joe
    ];
    home.sessionVariables.EDITOR = "joe";
  };
}
