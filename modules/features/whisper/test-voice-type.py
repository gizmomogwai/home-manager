import os
import math
from pathlib import Path
import shutil
import struct
import subprocess
import signal
import sys
import tempfile
import time
import wave
import config


script = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).with_name("voice-type.py")
constants = dict(
    (name, str(value)) for name, value in vars(config).items() if name.isupper()
)
real_recorder = sys.argv[2] if len(sys.argv) > 2 else ""
real_sox = shutil.which("sox")
real_soxi = shutil.which("soxi")
assert real_sox and real_soxi, "SoX is required for silence detection checks"
with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    binaries = root / "bin"
    binaries.mkdir()
    temporary = root / "tmp"
    temporary.mkdir()
    executable = f"#!{sys.executable}\n"
    commands = {
        "pw-record": """
import os, signal, time
from pathlib import Path
signal.signal(signal.SIGTERM, lambda *_: exit(1))
Path(os.environ["READY"]).touch()
if os.environ["MODE"] == "record-failure":
    exit(7)
if os.environ["MODE"] == "record-failure-one":
    exit(1)
while True:
    time.sleep(0.01)
""",
        "sox": """
import os, sys, time
from pathlib import Path
if "silence" not in sys.argv:
    os.execv(os.environ["REAL_SOX"], [os.environ["REAL_SOX"]] + sys.argv[1:])
threshold = os.environ.get("VOICE_SILENCE_THRESHOLD") or os.environ["TEST_DEFAULT_SILENCE_THRESHOLD"]
assert sys.argv[-7:] == [
    "silence", os.environ["TEST_SILENCE_START_COUNT"],
    os.environ["TEST_SILENCE_START_DURATION_SECONDS"], threshold,
    os.environ["TEST_SILENCE_STOP_COUNT"],
    os.environ["TEST_SILENCE_STOP_DURATION_SECONDS"], threshold,
]
assert sys.argv[sys.argv.index("--buffer") + 1] == os.environ["TEST_SOX_BUFFER_SIZE"]
if os.environ["REAL_RECORDER"]:
    os.execv(os.environ["REAL_SOX"], [os.environ["REAL_SOX"]] + sys.argv[1:])
mode = os.environ["MODE"]
target = next(value for value in sys.argv if value.endswith("audio.pcm"))
chunk_seconds = max(1, int(os.environ["TEST_MINIMUM_TRANSCRIPTION_AUDIO_SECONDS"]))
chunk = b"\\0" * (chunk_seconds * int(os.environ["TEST_AUDIO_BYTES_PER_SECOND"]))
typed = Path(os.environ["TYPED"])
def wait_for(text):
    deadline = time.monotonic() + 5
    while not (typed.exists() and typed.read_text() == text) and time.monotonic() < deadline:
        time.sleep(0.01)
with sys.stdin.buffer as stream, open(target, "wb") as audio:
    if mode == "silence-failure":
        exit(11)
    if mode not in ["record-failure-one", "no-speech"]:
        audio.write(chunk)
        audio.flush()
    if mode in ["live", "focus"]:
        wait_for("turn write at the")
        audio.write(chunk)
        audio.flush()
        wait_for("turn right at the next corner")
    elif mode in ["auto-stop", "word"]:
        time.sleep(0.4 if mode == "word" else 0.2)
    else:
        stream.read()
""",
        "whisper-cli": """
import os, sys, time, wave
from pathlib import Path
if os.environ["MODE"] == "transcribe-failure":
    exit(8)
if os.environ["MODE"] == "pass":
    Path(os.environ["PASS_READY"]).touch()
    time.sleep(0.3)
with wave.open(sys.argv[sys.argv.index("--file") + 1]) as recording:
    frames = recording.getnframes()
    assert frames > 0
    assert recording.getframerate() == int(os.environ["TEST_AUDIO_SAMPLE_RATE"])
    assert recording.getnchannels() == int(os.environ["TEST_AUDIO_CHANNELS"])
    assert recording.getsampwidth() * 8 == int(os.environ["TEST_AUDIO_BITS"])
assert sys.argv[sys.argv.index("--language") + 1] == os.environ["TEST_WHISPER_LANGUAGE"]
assert sys.argv[sys.argv.index("--beam-size") + 1] == os.environ["TEST_WHISPER_BEAM_SIZE"]
context = int(sys.argv[sys.argv.index("--audio-ctx") + 1])
units_per_second = int(os.environ["TEST_WHISPER_AUDIO_CONTEXT_UNITS_PER_SECOND"])
interim_context = frames * units_per_second // int(os.environ["TEST_AUDIO_SAMPLE_RATE"])
interim_context += int(os.environ["TEST_INTERIM_CONTEXT_PADDING_SECONDS"]) * units_per_second
if interim_context >= int(os.environ["TEST_WHISPER_FULL_AUDIO_CONTEXT_UNITS"]):
    interim_context = int(os.environ["TEST_WHISPER_DEFAULT_AUDIO_CONTEXT_UNITS"])
assert context in [int(os.environ["TEST_WHISPER_DEFAULT_AUDIO_CONTEXT_UNITS"]), interim_context]
output = sys.argv[sys.argv.index("--output-file") + 1]
text = " Yy Zz\\nworld\\r\\t\\x1b\\x00\\x7f\\\\n café äöüß [] {}\\n"
if os.environ["MODE"] == "empty":
    text = " \\n\\t"
elif os.environ["MODE"] == "word":
    text = " Hello\\n"
elif os.environ["MODE"] in ["live", "focus"]:
    chunk_seconds = max(1, int(os.environ["TEST_MINIMUM_TRANSCRIPTION_AUDIO_SECONDS"]))
    text = " turn write at the\\n" if frames < 2 * chunk_seconds * int(os.environ["TEST_AUDIO_SAMPLE_RATE"]) else " Turn right at the next corner.\\n"
Path(output + ".txt").write_text(text)
""",
        "xdotool": """
import os, sys
from pathlib import Path
typed = Path(os.environ["TYPED"])
arguments = sys.argv[1:]
if arguments == ["getwindowfocus"]:
    print(43 if os.environ["MODE"] == "focus" and typed.exists() else 42)
elif arguments[:3] == ["key", "--clearmodifiers", "--repeat"] and arguments[4:] == ["BackSpace"]:
    typed.write_text(typed.read_text()[:-int(arguments[3])])
elif arguments[:5] == ["type", "--clearmodifiers", "--delay", os.environ["TEST_KEY_DELAY_MILLISECONDS"], "--"] and len(arguments) == 6:
    if os.environ["MODE"] == "type-failure":
        exit(9)
    with typed.open("a") as stream:
        stream.write(arguments[5])
    with Path(os.environ["TYPED"] + ".log").open("a") as stream:
        stream.write(arguments[5] + "\\n")
else:
    exit(f"unexpected xdotool arguments: {arguments}")
""",
    }
    for name, content in commands.items():
        command = binaries / name
        command.write_text(executable + content)
        command.chmod(0o755)
    if real_recorder:
        (binaries / "pw-record").unlink()
        (binaries / "pw-record").symlink_to(real_recorder)

    modes = ["success", "hotkey"] if real_recorder else ["success", "record-failure", "record-failure-one", "silence-failure", "no-speech", "transcribe-failure", "empty", "type-failure", "cancel", "hotkey", "hotkey-cancel", "hotkey-failure", "auto-stop", "auto-stop-hotkey", "auto-stop-hotkey-live", "auto-stop-hotkey-focus", "auto-stop-hotkey-word"]
    if not real_recorder:
        modes += ["hotkey-stop-during-pass", "hotkey-cancel-during-pass"]
    for mode in modes:
        ready = root / f"{mode}.ready"
        typed = root / f"{mode}.typed"
        hotkey_mode = "hotkey" in mode
        recorder_mode = "pass" if mode.endswith("during-pass") else "record-failure-one" if mode == "hotkey-failure" else mode.rsplit("-", 1)[1] if mode.endswith(("-live", "-focus", "-word")) else "auto-stop" if mode.startswith("auto-stop") else mode
        environment = dict(os.environ, PATH=f"{binaries}:{os.environ['PATH']}",
                           TMPDIR=str(temporary), WHISPER_MODEL="test-model",
                           MODE=recorder_mode, READY=str(ready), TYPED=str(typed),
                           PASS_READY=str(root / f"{mode}.pass"),
                           REAL_RECORDER=real_recorder,
                           REAL_SOX=real_sox or "")
        environment.update({f"TEST_{name}": value for name, value in constants.items()})
        if real_recorder:
            environment["VOICE_SILENCE_THRESHOLD"] = "0%"
        process = subprocess.Popen(
            [sys.executable, str(script)] + (["--hotkey"] if hotkey_mode else []),
            stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
            text=True, env=environment,
        )
        try:
            if real_recorder:
                time.sleep(0.5)
            else:
                deadline = time.monotonic() + 5
                while not ready.exists() and process.poll() is None and time.monotonic() < deadline:
                    time.sleep(0.01)
                assert ready.exists(), f"{mode}: recorder did not start"
            if mode.startswith("record-failure"):
                time.sleep(0.1)
            if hotkey_mode:
                assert process.stdout.readline().strip() == "recording"
                if mode.endswith("during-pass"):
                    deadline = time.monotonic() + 5
                    while not Path(environment["PASS_READY"]).exists() and process.poll() is None and time.monotonic() < deadline:
                        time.sleep(0.01)
                    assert Path(environment["PASS_READY"]).exists(), (mode, "transcription did not start")
                if mode != "hotkey-failure" and not mode.startswith("auto-stop"):
                    process.send_signal(signal.SIGTERM if "cancel" in mode else signal.SIGUSR1)
            if mode.startswith("auto-stop"):
                process.wait(timeout=5)
            _, errors = process.communicate("" if mode == "cancel" or hotkey_mode else "\n", timeout=5)
            expected = {"auto-stop-hotkey-live": "Turn right at the next corner.", "auto-stop-hotkey-focus": "turn write at the", "auto-stop-hotkey-word": "Hello"}.get(
                mode, "Yy Zz world \\n café äöüß [] {}" if mode in ["success", "hotkey", "auto-stop", "auto-stop-hotkey", "hotkey-stop-during-pass"] else None)
            assert (process.returncode == 0) == (expected is not None and mode != "auto-stop-hotkey-focus"), (mode, errors)
            assert "unbound variable" not in errors, (mode, errors)
            # A live pass may already have typed the text before a late failure.
            allowed = [expected] if expected else [None, "Yy Zz world \\n café äöüß [] {}"]
            assert (typed.read_text() if typed.exists() else None) in allowed, (mode, errors)
            if mode == "auto-stop-hotkey-live":
                # Interim correction retypes only the changed words; the final pass fixes the capital.
                assert Path(f"{typed}.log").read_text() == "turn write at the\nright at the next corner\nTurn right at the next corner.\n"
            if mode == "auto-stop-hotkey-focus":
                assert "lost focus" in errors, errors
            if "cancel" in mode and hotkey_mode:
                assert process.returncode == 143, (mode, errors)
            assert not list(temporary.iterdir()), (mode, "temporary audio was not removed", errors)
        finally:
            if process.poll() is None:
                process.terminate()
                process.communicate(timeout=5)
    if real_sox:
        stop_seconds = float(constants["SILENCE_STOP_DURATION_SECONDS"])
        start_seconds = float(constants["SILENCE_START_DURATION_SECONDS"])
        sample_rate = int(constants["AUDIO_SAMPLE_RATE"])
        boundary_margin = min(0.1, stop_seconds / 4)
        speech_seconds = max(0.3, start_seconds * 2)
        for gap, expected_stop in [(stop_seconds - boundary_margin, False), (stop_seconds + boundary_margin, True)]:
            source = root / "silence-input.wav"
            target = root / "silence-output.wav"
            samples = []
            for duration, amplitude in [(2, 0.01), (speech_seconds, 0.2), (gap, 0.01), (speech_seconds, 0.2), (stop_seconds + boundary_margin, 0.01)]:
                samples.extend(int(32767 * amplitude * math.sin(2 * math.pi * 440 * index / sample_rate))
                               for index in range(round(duration * sample_rate)))
            with wave.open(str(source), "wb") as audio:
                audio.setnchannels(1)
                audio.setsampwidth(2)
                audio.setframerate(sample_rate)
                audio.writeframes(struct.pack(f"<{len(samples)}h", *samples))
            # A fixed fixture threshold separates quiet background from the test tone.
            subprocess.run([
                real_sox, str(source), str(target), "silence",
                constants["SILENCE_START_COUNT"], constants["SILENCE_START_DURATION_SECONDS"], "3%",
                constants["SILENCE_STOP_COUNT"], constants["SILENCE_STOP_DURATION_SECONDS"], "3%",
            ], check=True)
            with wave.open(str(target)) as audio:
                duration = audio.getnframes() / audio.getframerate()
                assert (duration < 2 * speech_seconds) == expected_stop, (gap, duration)
                if not expected_stop:
                    assert duration > gap + speech_seconds, (gap, duration)
print("voice-type checks passed")
