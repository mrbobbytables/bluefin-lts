#!/usr/bin/bash

set -eoux pipefail

echo "::group:: ===$(basename "$0")==="

# Install tooling
dnf -y install glib2-devel meson sassc cmake dbus-devel

# Build Extensions

# AppIndicator Support
glib-compile-schemas --strict /usr/share/gnome-shell/extensions/appindicatorsupport@rgcjonas.gmail.com/schemas

# Bazaar Companion
mv /usr/share/gnome-shell/extensions/tmp/bazaar-integration@kolunmi.github.io/src/ /usr/share/gnome-shell/extensions/bazaar-integration@kolunmi.github.io/

# Blur My Shell
make -C /usr/share/gnome-shell/extensions/blur-my-shell@aunetx
unzip -o /usr/share/gnome-shell/extensions/blur-my-shell@aunetx/build/blur-my-shell@aunetx.shell-extension.zip -d /usr/share/gnome-shell/extensions/blur-my-shell@aunetx
glib-compile-schemas --strict /usr/share/gnome-shell/extensions/blur-my-shell@aunetx/schemas
rm -rf /usr/share/gnome-shell/extensions/blur-my-shell@aunetx/build

# Caffeine
# The Caffeine extension is built/packaged into a temporary subdirectory (tmp/caffeine/caffeine@patapon.info).
# Unlike other extensions, it must be moved to the standard extensions directory so GNOME Shell can detect it.
mv /usr/share/gnome-shell/extensions/tmp/caffeine/caffeine@patapon.info /usr/share/gnome-shell/extensions/caffeine@patapon.info
glib-compile-schemas --strict /usr/share/gnome-shell/extensions/caffeine@patapon.info/schemas

# Dash to Dock
make -C /usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com
glib-compile-schemas --strict /usr/share/gnome-shell/extensions/dash-to-dock@micxgx.gmail.com/schemas

# Gradia Capture
bash /usr/share/gnome-shell/extensions/gradia-integration@alexandervanhee.github.io/build.sh
unzip -o /usr/share/gnome-shell/extensions/gradia-integration@alexandervanhee.github.io/gradia-integration@alexandervanhee.github.io.shell-extension.zip -d /usr/share/gnome-shell/extensions/gradia-integration@alexandervanhee.github.io
rm -f /usr/share/gnome-shell/extensions/gradia-integration@alexandervanhee.github.io/gradia-integration@alexandervanhee.github.io.shell-extension.zip
glib-compile-schemas --strict /usr/share/gnome-shell/extensions/gradia-integration@alexandervanhee.github.io/schemas

# GSConnect
meson setup --prefix=/usr /usr/share/gnome-shell/extensions/gsconnect@andyholmes.github.io /usr/share/gnome-shell/extensions/gsconnect@andyholmes.github.io/_build
meson install -C /usr/share/gnome-shell/extensions/gsconnect@andyholmes.github.io/_build --skip-subprojects
# GSConnect installs schemas to /usr/share/glib-2.0/schemas and meson compiles them automatically

# Custom Command Menu
glib-compile-schemas --strict /usr/share/gnome-shell/extensions/custom-command-list@storageb.github.com/schemas

# Search Light
glib-compile-schemas --strict /usr/share/gnome-shell/extensions/search-light@icedman.github.com/schemas

# Quick Settings Audio Panel
# Ships as a prebuilt .shell-extension.zip release asset (no source build required).
# Version is pinned in image-versions.yaml and tracked by Renovate.
QSAP_UUID="quick-settings-audio-panel@rayzeq.github.io"
QSAP_VERSION=$(grep '^\s*quick_settings_audio_panel:' /run/context/image-versions.yaml | sed 's/.*"\(.*\)".*/\1/')
QSAP_DIR="/usr/share/gnome-shell/extensions/${QSAP_UUID}"
mkdir -p "${QSAP_DIR}"
curl -fsSL "https://github.com/Rayzeq/quick-settings-audio-panel/releases/download/${QSAP_VERSION}/${QSAP_UUID}.shell-extension.zip" \
    -o /tmp/qsap.shell-extension.zip
unzip -o /tmp/qsap.shell-extension.zip -d "${QSAP_DIR}"
rm -f /tmp/qsap.shell-extension.zip
glib-compile-schemas --strict "${QSAP_DIR}/schemas"
install -Dm644 "${QSAP_DIR}/schemas/org.gnome.shell.extensions.quick-settings-audio-panel.gschema.xml" \
    "/usr/share/glib-2.0/schemas/org.gnome.shell.extensions.quick-settings-audio-panel.gschema.xml"

rm /usr/share/glib-2.0/schemas/gschemas.compiled
glib-compile-schemas /usr/share/glib-2.0/schemas

# Cleanup
dnf -y remove glib2-devel meson sassc cmake dbus-devel
rm -rf /usr/share/gnome-shell/extensions/tmp

echo "::endgroup::"
