source: https://github.com/mixxxdj/mixxx/blob/main/tools/debian_buildenv.sh
Some packages still miss, so verify the file again.
missing part to check:
        # If jackd2 is installed as per dpkg database, install libjack-jackd2-dev.
        # This avoids a package deadlock, resulting in jackd2 being removed, and jackd1 being installed,
        # to satisfy portaudio19-dev's need for a jackd dev package. In short, portaudio19-dev needs a
        # jackd dev library, so let's give it one..
        if [ "$(dpkg-query -W -f='${Status}' jackd2 2>/dev/null | grep -c "ok installed")" -eq 1 ];
        then
            sudo apt-get install libjack-jackd2-dev;
        fi

        # Install a faster linker. Prefer mold, fall back to lld
        if apt-cache show mold 2>%1 >/dev/null;
        then
            sudo apt-get install -y --no-install-recommends mold
        else
            if apt-cache show lld 2>%1 >/dev/null;
            then
                sudo apt-get install -y --no-install-recommends lld
            fi
        fi

## found in pacman or yay:
mold
ccache
cmake
clazy

## Not found yet
libavformat-dev
clang-tidy
debhelper

## TODO
devscripts
docbook-to-man
dput
fonts-open-sans
fonts-ubuntu
g++
lcov
libbenchmark-dev
libchromaprint-dev
libdistro-info-perl
libebur128-dev
libfaad-dev
libfftw3-dev
libflac-dev
libgmock-dev
libgtest-dev
libgl1-mesa-dev
libhidapi-dev
libid3tag0-dev
liblilv-dev
libmad0-dev
libmodplug-dev
libmp3lame-dev
libmsgsl-dev
libopus-dev
libopusfile-dev
libportmidi-dev
libprotobuf-dev
libqt6core5compat6-dev
libqt6opengl6-dev
libqt6sql6-sqlite
libqt6svg6-dev
librubberband-dev
libshout-idjc-dev
libsndfile1-dev
libsoundtouch-dev
libsqlite3-dev
libssl-dev
libtag1-dev
libudev-dev
libupower-glib-dev
libusb-1.0-0-dev
libwavpack-dev
lv2-dev
markdown
portaudio19-dev
protobuf-compiler
qtkeychain-qt6-dev
qt6-declarative-dev
qml-module-qtquick-controls
qml-module-qtquick-controls2
qml-module-qt-labs-qmlmodels
qml-module-qtquick-shapes
