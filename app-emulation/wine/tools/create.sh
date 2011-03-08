#!/bin/sh -x

PROFILE="$1"
if [ -z "$1" ]; then
 echo 'Missing argument: profile name'
 exit 1
fi

export WINEARCH="win32"
export WINECELLAR="$HOME/Wine"
export WINEPREFIX="$WINECELLAR/$PROFILE"

mkdir -p "$WINEPREFIX" "$WINEPREFIX/loop" "$WINEPREFIX/home" "$WINEPREFIX/drive_c/wine"

cd "$WINEPREFIX/drive_c"
winecfg

for I in `seq 1 5 ` ; do
# wait for registry
 sleep 3
 test -s "$WINEPREFIX/system.reg" && break
done
sleep 1

#############################################################################

ln -sfn ../loop  "$WINEPREFIX/dosdevices/d:"
ln -sfn /usr/share/fonts "$WINEPREFIX/dosdevices/f:"
ln -sfn .. "$WINEPREFIX/dosdevices/p:"
ln -sfn ../../drive_t "$WINEPREFIX/dosdevices/t:"
ln -sfn /usr/share/wine "$WINEPREFIX/dosdevices/w:"
rm "$WINEPREFIX/dosdevices/z:"

echo 0 > "$WINEPREFIX/drive_c/wine/track_usage"

cp -f -v  "$WINECELLAR/winemenubuilder.exe" "$WINEPREFIX/drive_c/windows/system32/"

for D in "Desktop" "My Documents" "My Music" "My Pictures" "My Videos"
do
    ln -sfn ../../../home "${WINEPREFIX}/drive_c/users/${USER}/${D}"
done

#############################################################################

cat > "$WINEPREFIX/drive_c/wine/setup.reg" << EOT
REGEDIT4

[HKEY_LOCAL_MACHINE\Software\Wine\Drives]
"d:"="cdrom"

[HKEY_CURRENT_USER\Software\Wine\DllOverrides]
"winemenubuilder.exe"="native"

[HKEY_CURRENT_USER\Software\Wine\WineDbg]
"ShowCrashDialog"=dword:00000000
EOT

wine regedit "c:\\wine\\setup.reg"

#############################################################################

cat > "$WINEPREFIX/config.sh" << EOT
#!/bin/sh -x
PROFILE="$PROFILE"

export WINEARCH=win32
export WINEPREFIX="\$HOME/Wine/\$PROFILE"
#export WINEDEBUG=-all

cd "\$WINEPREFIX/drive_c"

winecfg

EOT

#############################################################################

cat > "$WINEPREFIX/run.sh" << EOT
#!/bin/sh -x

PROFILE="$PROFILE"
ISOFILE=

# english locale
#export LC_ALL=en_US
#export LANG=en_US

export WINEARCH=win32
export WINEPREFIX="\$HOME/Wine/\$PROFILE"
#export WINEDEBUG=-all

cd "\$WINEPREFIX"
if test -n "\$ISOFILE" ; then
  test -n  "\`ls loop/\`"  &&  fusermount -z -u "\$WINEPREFIX/loop"
  fuseiso "\$ISOFILE" "\$WINEPREFIX/loop" || exit 1
fi

cd drive_c
# cpu freq
#xrandr -s 1024x768
#sudo cpufreq-set -g performance  || echo cpu perf. setting failed

#taskset 01 wine "c:\\\\game\\\\game.exe"
taskset 01 wine "t:\\\\totalcmd\\\\totalcmd.exe"

if test -n "\$ISOFILE" ; then
  fusermount -z -u "\$WINEPREFIX/loop"
fi

### restore settings

#sudo cpufreq-set -g ondemand  || echo cpu perf. setting failed
#xrandr -s 1440x900 -r 54
#nvidia-settings -l

EOT

#############################################################################

cat > "$WINEPREFIX/winetricks.sh" << EOT
#!/bin/sh -x
PROFILE="$PROFILE"

export WINEARCH=win32
export WINEPREFIX="\$HOME/Wine/\$PROFILE"
export WINETRICKS_CACHE="\$WINEPREFIX/drive_c/wine"
export W_CACHE="\$WINETRICKS_CACHE"
#export WINEDEBUG=-all

cd "\$WINETRICKS_CACHE"

wget -nc http://www.kegel.com/wine/winetricks || exit 1

chmod 755 winetricks

exec ./winetricks  "\$@"

EOT

#############################################################################

chmod 755 "$WINEPREFIX/run.sh" "$WINEPREFIX/config.sh" "$WINEPREFIX/winetricks.sh"


