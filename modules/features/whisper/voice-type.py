#!/usr/bin/env python3
# Awesome WM: Super+S launches voice-type --hotkey with stdout captured; another press sends SIGUSR1 to stop recording.
# pw-record: PipeWire microphone -> raw s16 samples on stdout -> pipe connected to SoX stdin.
# SoX: raw samples on stdin -> silence detection -> growing audio.pcm file; repeated conversions produce audio.wav snapshots.
# whisper-cli: audio.wav snapshot -> transcript.txt file; repeated full-so-far passes emulate streaming, followed by a final pass.
# Python: transcript.txt -> sanitized text in memory -> compare with previously typed text to find corrections.
# (Flatten newlines/tabs and strip other controls so xdotool cannot turn transcript text into Enter/shortcuts.)
# Python / Awesome WM (status only): "recording" or "transcribing" + newline on stdout -> Awesome's line reader -> status notification.
# xdotool (text only): corrections as command-line arguments -> BackSpace/type key events -> original focused X window/terminal.
import os
from pathlib import Path
import select
import signal
import subprocess
import sys
import tempfile
import time

import config


def fail(message, status=1):
    print(message, file=sys.stderr)
    raise SystemExit(status)


def main():
    if sys.argv[1:] not in [[], ["--hotkey"]]:
        fail("Usage: voice-type [--hotkey]", 2)
    hotkey_mode = bool(sys.argv[1:])
    silence_threshold = os.environ.get("VOICE_SILENCE_THRESHOLD") or config.DEFAULT_SILENCE_THRESHOLD
    stop_requested = False
    recording = None
    processes = []
    typed = ""
    transcribed_bytes = 0

    def stop_recording(signal_number=None, frame=None):
        nonlocal stop_requested
        stop_requested = True
        if recording is not None and recording.poll() is None:
            recording.terminate()

    def cancel(signal_number, frame):
        raise SystemExit(128 + signal_number)

    signal.signal(signal.SIGINT, cancel)
    signal.signal(signal.SIGTERM, cancel)
    if hotkey_mode:
        signal.signal(signal.SIGUSR1, stop_recording)

    def focused_window():
        return subprocess.check_output(["xdotool", "getwindowfocus"], text=True).strip()

    target_window = focused_window()
    raw_options = [
        "--type", "raw", "--encoding", "signed-integer", "--bits", str(config.AUDIO_BITS),
        "--channels", str(config.AUDIO_CHANNELS), "--rate", str(config.AUDIO_SAMPLE_RATE),
    ]
    with tempfile.TemporaryDirectory() as directory:
        work_directory = Path(directory)
        audio = work_directory / "audio.pcm"
        audio.touch()

        def live_update(final=False):
            nonlocal typed
            audio_context = config.WHISPER_DEFAULT_AUDIO_CONTEXT_UNITS
            if not final:
                audio_context = int(
                    transcribed_bytes * config.WHISPER_AUDIO_CONTEXT_UNITS_PER_SECOND
                    / config.AUDIO_BYTES_PER_SECOND
                    + config.INTERIM_CONTEXT_PADDING_SECONDS * config.WHISPER_AUDIO_CONTEXT_UNITS_PER_SECOND
                )
                if audio_context >= config.WHISPER_FULL_AUDIO_CONTEXT_UNITS:
                    audio_context = config.WHISPER_DEFAULT_AUDIO_CONTEXT_UNITS
            subprocess.run([
                "sox", "--no-show-progress", *raw_options, str(audio), str(work_directory / "audio.wav"),
            ], check=True)
            with (work_directory / "whisper.log").open("w") as log:
                transcription = subprocess.Popen([
                    "whisper-cli", "--model", os.environ["WHISPER_MODEL"],
                    "--file", str(work_directory / "audio.wav"), "--language", config.WHISPER_LANGUAGE,
                    "--output-txt", "--output-file", str(work_directory / "transcript"), "--no-prints",
                    "--beam-size", str(config.WHISPER_BEAM_SIZE), "--audio-ctx", str(audio_context),
                ], stdout=subprocess.DEVNULL, stderr=log)
                processes.append(transcription)
                status = transcription.wait()
            if status:
                print((work_directory / "whisper.log").read_text(), end="", file=sys.stderr)
                fail(f"Transcription failed (exit {status}).", status if status > 0 else 128 - status)
            text = (work_directory / "transcript.txt").read_text()
            text = text.translate(str.maketrans("\r\n\t", "   "))
            text = "".join(character for character in text if ord(character) >= 32 and ord(character) != 127)
            text = " ".join(part for part in text.split(" ") if part)
            if not text:
                if final:
                    fail("No speech recognized.")
                return
            if not final:
                old_words, new_words = typed.split(), text.split()
                kept = 0
                for old_word, new_word in zip(old_words, new_words):
                    normalize = lambda word: "".join(character for character in word.lower() if character.isalnum())
                    if normalize(old_word) != normalize(new_word):
                        break
                    kept += 1
                text = " ".join(old_words[:kept] + new_words[kept:]).rstrip(".,-")
            if typed == text:
                return
            common = 0
            for old_character, new_character in zip(typed, text):
                if old_character != new_character:
                    break
                common += 1
            if focused_window() != target_window:
                fail("Stopped: target window lost focus.")
            if len(typed) > common:
                subprocess.run([
                    "xdotool", "key", "--clearmodifiers", "--repeat", str(len(typed) - common), "BackSpace",
                ], check=True)
            if len(text) > common:
                subprocess.run([
                    "xdotool", "type", "--clearmodifiers", "--delay", str(config.KEY_DELAY_MILLISECONDS),
                    "--", text[common:],
                ], check=True)
            typed = text

        try:
            recording = subprocess.Popen([
                "pw-record", "--raw", f"--rate={config.AUDIO_SAMPLE_RATE}",
                f"--channels={config.AUDIO_CHANNELS}", f"--format=s{config.AUDIO_BITS}", "-",
            ], stdin=subprocess.DEVNULL, stdout=subprocess.PIPE)
            processes.append(recording)
            silence = subprocess.Popen([
                "sox", "--no-show-progress", "--buffer", str(config.SOX_BUFFER_SIZE), *raw_options,
                "-", "--type", "raw", str(audio), "silence", str(config.SILENCE_START_COUNT),
                str(config.SILENCE_START_DURATION_SECONDS), silence_threshold, str(config.SILENCE_STOP_COUNT),
                str(config.SILENCE_STOP_DURATION_SECONDS), silence_threshold,
            ], stdin=recording.stdout)
            processes.append(silence)
            recording.stdout.close()
            if hotkey_mode:
                print("recording", flush=True)
            else:
                print(
                    f"Recording. A {config.SILENCE_STOP_DURATION_SECONDS}-second pause stops it; "
                    "Enter stops now; Ctrl+C cancels.", file=sys.stderr,
                )
            if stop_requested:
                stop_recording()
            while not stop_requested and silence.poll() is None:
                if hotkey_mode:
                    time.sleep(config.INPUT_POLL_INTERVAL_SECONDS)
                elif select.select([sys.stdin], [], [], config.INPUT_POLL_INTERVAL_SECONDS)[0]:
                    input_bytes = os.read(sys.stdin.fileno(), 4096)
                    if not input_bytes:
                        fail("Recording cancelled: input closed.")
                    if b"\n" in input_bytes:
                        stop_recording()
                        break
                recorded_bytes = audio.stat().st_size
                if recorded_bytes >= config.MINIMUM_TRANSCRIPTION_AUDIO_SECONDS * config.AUDIO_BYTES_PER_SECOND and recorded_bytes != transcribed_bytes:
                    transcribed_bytes = recorded_bytes
                    live_update()
            status = silence.wait()
            if hotkey_mode:
                signal.signal(signal.SIGUSR1, signal.SIG_IGN)
            if status:
                fail(f"Silence detection failed (exit {status}).", status if status > 0 else 128 - status)
            stop_recording()
            status = recording.wait()
            # Recorder shutdown may report 1, SIGPIPE, or SIGTERM after the silence filter exits.
            if status not in (0, 1, -signal.SIGPIPE, -signal.SIGTERM, 141, 143):
                fail(f"Recording failed (exit {status}).", status if status > 0 else 128 - status)
            if not audio.stat().st_size:
                fail(f"No speech recorded above silence threshold {silence_threshold}.")
            if hotkey_mode:
                print("transcribing", flush=True)
            else:
                print("Finishing. Keep target window focused.", file=sys.stderr)
            live_update(final=True)
        finally:
            for process in reversed(processes):
                if process.poll() is None:
                    process.terminate()
                    try:
                        process.wait(timeout=2)
                    except subprocess.TimeoutExpired:
                        process.kill()
                        process.wait()


if __name__ == "__main__":
    try:
        main()
    except (OSError, subprocess.CalledProcessError, KeyError) as error:
        fail(str(error), error.returncode if isinstance(error, subprocess.CalledProcessError) and error.returncode > 0 else 1)
