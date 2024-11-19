rm -rf builds/Web
mkdir builds/Web
godot4_3 --export-debug --headless Web
echo "Export complete"
zip -r builds/Web.zip builds/Web
echo "Zip complete"
