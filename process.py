#!/usr/bin/env python3

from glob import glob
import os
import json

files = glob("input/**", recursive=True)
files = [file for file in files if os.path.isfile(file)]

theme = {}
with open("theme.json", "r") as f:
    theme = json.load(f)

for file in files:
    destination = ".config" + file.lstrip("input")
    destination_dir = os.path.split(destination)[0]

    os.makedirs(destination_dir, exist_ok=True)

    source = ""
    with open(file, "r") as f:
        source = f.read()

    for key, value in theme.items():
        source = source.replace(f"@{key}@", value.replace("#", ""))

    with open(destination, "w") as f:
        f.write(source)

    if source.splitlines()[0].strip() == "#!/usr/bin/env bash":
        os.chmod(destination, 0o755)
