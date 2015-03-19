Name:       jolla-camera
Summary:    Jolla Camera application
Version:    0.0.1
Release:    1
Group:      Applications/Multimedia
License:    TBD
URL:        https://bitbucket.org/jolla/ui-jolla-camera
Source0:    %{name}-%{version}.tar.bz2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Gui)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Network)
BuildRequires:  pkgconfig(Qt5Multimedia)
BuildRequires:  desktop-file-utils
BuildRequires:  pkgconfig(qdeclarative5-boostable)
BuildRequires:  pkgconfig(mlite5) >= 0.2.5
BuildRequires:  qt5-qttools
BuildRequires:  qt5-qttools-linguist
BuildRequires:  pkgconfig(gstreamer-0.10)
BuildRequires:  oneshot

Requires:  jolla-ambient >= 0.4.10
Requires:  jolla-settings-accounts >= 0.1.31
Requires:  sailfishsilica-qt5 >= 0.13.44
Requires:  mapplauncherd-booster-silica-qt5
Requires:  qt5-qtdeclarative-import-models2
Requires:  qt5-qtdeclarative-import-positioning
Requires: qt5-qtdeclarative-import-multimedia
Requires: qt5-qtmultimedia-plugin-mediaservice-gstcamerabin >= 5.1.0+git25
Requires: qt5-qtmultimedia-plugin-mediaservice-gstmediaplayer
Requires:  declarative-transferengine-qt5 >= 0.0.49
Requires:  nemo-qml-plugin-thumbnailer-qt5-video
Requires:  nemo-qml-plugin-thumbnailer-qt5
Requires:  nemo-qml-plugin-dbus-qt5
Requires:  nemo-qml-plugin-policy-qt5
Requires:  nemo-qml-plugin-time-qt5
Requires:  nemo-qml-plugin-configuration-qt5
Requires:  sailfish-components-media-qt5 >= 0.0.18
Requires:  sailfish-components-gallery-qt5 >= 0.0.48
Requires:  libjollasignonuiservice-qt5-plugin >= 0.0.29
Requires:  libngf-qt5-declarative
Requires:  ambienced
Requires:  gst-plugins-good >= 0.10.31+git3
Requires:  gst-plugins-bad
Requires:  dconf
Requires:  %{name}-settings = %{version}
%{_oneshot_requires_post}

%description
The Jolla Camera application.

%package ts-devel
Summary:   Translation source for Jolla Camera
License:   TBD
Group:     Applications/Multimedia

%description ts-devel
Translation source for Jolla Camera

%package settings
Summary:   Setting page for jolla-camera
License:   TBD
Group:     System/Applications
Requires:   %{name} = %{version}-%{release}
Requires:  jolla-settings

%description settings
Settings page for jolla-contacts
%package tests
Summary:    Unit tests for Jolla Camera
Group:      Applications/Multimedia
BuildRequires:  pkgconfig(Qt5Test)
BuildRequires:  pkgconfig(Qt5Multimedia)
Requires:   %{name} = %{version}-%{release}
Requires:   qt5-qtdeclarative-import-qttest
Requires:   qt5-qtdeclarative-devel-tools
Requires:   dbus-x11

%description tests
This package contains QML unit tests for Jolla Camera application

%prep
%setup -q -n %{name}-%{version}

%build

%qmake5 %{name}.pro

make %{?jobs:-j%jobs}

%install
rm -rf %{buildroot}
%qmake5_install
chmod +x %{buildroot}/opt/tests/jolla-camera/auto/run-tests.sh

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop
chmod +x %{buildroot}/%{_oneshotdir}/*

%files
%defattr(-,root,root,-)
%{_datadir}/applications/*.desktop
%{_datadir}/jolla-camera/*
%{_bindir}/jolla-camera
%{_datadir}/translations/jolla-camera_eng_en.qm
%{_datadir}/dbus-1/services/com.jolla.camera.service
%{_libdir}/qt5/qml/com/jolla/camera/libjollacameraplugin.so
%{_libdir}/qt5/qml/com/jolla/camera/qmldir
%{_libdir}/qt5/qml/com/jolla/camera/settings.qml
%{_sysconfdir}/dconf/db/vendor.d/jolla-camera.txt
%{_oneshotdir}/enable-camera-hints

%files ts-devel
%defattr(-,root,root,-)
%{_datadir}/translations/source/jolla-camera.ts

%files settings
%{_datadir}/jolla-settings/*

%files tests
%defattr(-,root,root,-)
# >> files tests
/opt/tests/jolla-camera/*
# << files tests

%post
%{_bindir}/add-oneshot dconf-update
if [ "$1" -eq 1 ]; then
%{_bindir}/add-oneshot --user --now enable-camera-hints
fi


