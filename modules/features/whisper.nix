{
  flake.modules.homeManager.whisper = {
    pkgs,
    ...
  }: let
    model = pkgs.fetchurl {
      url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.en.bin";
      hash = "sha256-xhONbVjsyDIgl+D5h8MvG+i7ChhTKj+I9zTRu/nEHl0=";
    };
    voiceType = pkgs.writeShellApplication {
      name = "voice-type";
      runtimeInputs = with pkgs; [pipewire sox whisper-cpp xdotool];
      runtimeEnv.WHISPER_MODEL = "${model}";
      text = ''exec ${pkgs.python3}/bin/python ${./whisper}/voice-type.py "$@"'';
      checkPhase = ''
        ${pkgs.shellcheck}/bin/shellcheck "$target"
        PATH="${pkgs.sox}/bin:$PATH" ${pkgs.python3}/bin/python ${./whisper}/test-voice-type.py
      '';
    };
  in {
    home.packages = with pkgs; [
      lame
      sox
      whisper-cpp
      voiceType
    ];
    xdg.dataFile."whisper.cpp/ggml-small.en.bin".source = model;
  };
}
