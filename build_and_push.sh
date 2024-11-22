rm -rf builds/Web
mkdir builds/Web
godot4_3 --export-debug --headless Web
echo "Export complete"
zip -r builds/Web.zip builds/Web
echo "Zip complete"
./butler/butler push builds/Web.zip ThisIsRob/flipbook-racer:web --userversion 1.0.0
echo "Pushed to itch"
