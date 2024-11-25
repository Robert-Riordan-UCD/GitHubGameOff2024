rm -rf builds
mkdir -p builds/Web builds/Linux builds/Windows
godot4_3 --export-release --headless Web
godot4_3 --export-release --headless Linux
godot4_3 --export-release --headless "Windows Desktop"
echo "Export complete"
./butler/butler push builds/Web ThisIsRob/notepad-ace:web --userversion 1.0.0
./butler/butler push builds/Linux/ ThisIsRob/notepad-ace:linux --userversion 1.0.0
./butler/butler push builds/Windows ThisIsRob/notepad-ace:win-64 --userversion 1.0.0
echo "Pushed to itch"
