import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


script = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).with_name("dev-build.sh")
bash = shutil.which("bash")
assert bash, "Bash is required"

with tempfile.TemporaryDirectory() as directory:
    root = Path(directory)
    commands = {
        "grep": """
import os, sys
assert sys.argv[1:3] in [["--quiet", "--fixed-strings"], ["--quiet", "--word-regexp"]]
if sys.argv[-1] == "/proc/self/cgroup":
    exit(0 if os.environ["MODE"] == "nested" else 1)
assert sys.argv[-1] == "/sys/fs/cgroup/user.slice/test/cgroup.controllers"
exit(1 if os.environ["MODE"] == "no-cpu" else 0)
""",
        "systemctl": """
import os, sys
assert sys.argv[1:] == ["--user", "show", "--property=ControlGroup", "--value"]
if os.environ["MODE"] == "no-manager":
    print("user manager unavailable", file=sys.stderr)
    exit(7)
print("" if os.environ["MODE"] == "empty-group" else "/user.slice/test")
""",
        "systemd-run": """
import json, os, sys
from pathlib import Path
arguments = sys.argv[1:]
assert arguments[:6] == ["--user", "--scope", "--quiet", "--slice=devbuild.slice",
                         "--expand-environment=no", "--"]
Path(os.environ["SCOPE_LOG"]).write_text(json.dumps(arguments[6:]))
if os.environ["MODE"] == "scope-failure":
    print("scope failed", file=sys.stderr)
    exit(9)
os.execv(arguments[6], arguments[6:])
""",
    }
    for name, content in commands.items():
        executable = root / name
        executable.write_text(f"#!{sys.executable}\n{content}")
        executable.chmod(0o755)

    scope_log = root / "scope.json"
    arguments = [
        sys.executable, "-c",
        "import json, os, sys; print(json.dumps([sys.argv[1:], os.getcwd(), "
        "os.environ['BUILD_VALUE'], sys.stdin.read()])); sys.exit(13)",
        "space here", "$literal", "",
    ]
    # -c supplies Python code; Python has no long form.
    for mode in ["normal", "nested", "no-cpu", "no-manager", "empty-group", "scope-failure"]:
        scope_log.unlink(missing_ok=True)
        environment = dict(os.environ, PATH=str(root), MODE=mode,
                           SCOPE_LOG=str(scope_log), BUILD_VALUE="kept")
        result = subprocess.run([bash, str(script), *arguments], cwd=root, env=environment,
                                input="stdin preserved", capture_output=True, text=True, timeout=5)
        expected_status = {"normal": 13, "nested": 13, "no-manager": 7,
                           "scope-failure": 9}.get(mode, 1)
        assert result.returncode == expected_status, (mode, result)
        if mode in ["normal", "nested"]:
            assert json.loads(result.stdout) == [
                ["space here", "$literal", ""], str(root), "kept", "stdin preserved",
            ], result
        else:
            assert result.stderr and not result.stdout, (mode, result)
        assert scope_log.exists() == (mode in ["normal", "scope-failure"]), mode
        if scope_log.exists():
            assert json.loads(scope_log.read_text()) == arguments

    environment["MODE"] = "normal"
    result = subprocess.run([bash, str(script)], env=environment, capture_output=True, text=True)
    assert result.returncode == 2 and "Usage:" in result.stderr
    result = subprocess.run([bash, str(script), "/missing-build-command"],
                            env=environment, capture_output=True, text=True)
    assert result.returncode != 0 and result.stderr
    (root / "systemd-run").unlink()
    result = subprocess.run([bash, str(script), *arguments],
                            env=environment, capture_output=True, text=True)
    assert result.returncode == 1 and "requires systemd-run" in result.stderr

print("dev-build checks passed")
