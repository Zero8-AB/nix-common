system:
if system == "x86_64-linux"
then "linux-x64"
else if system == "aarch64-linux"
then "linux-arm64"
else throw "Unsupported system for container build: ${system}"
