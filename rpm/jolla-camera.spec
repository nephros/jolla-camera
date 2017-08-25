Name:       jolla-camera
Summary:    Jolla Camera application
Version:    0.4.11
Release:    1
Group:      Applications/Multimedia
License:    Proprietary
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
BuildRequires:  pkgconfig(systemsettings) >= 0.2.13
BuildRequires:  qt5-qttools
BuildRequires:  qt5-qttools-linguist
BuildRequires:  oneshot

Requires:  jolla-settings-accounts >= 0.1.31
Requires:  sailfishsilica-qt5 >= 0.13.44
Requires:  mapplauncherd >= 4.1.22
Requires:  mapplauncherd-booster-silica-qt5
Requires:  qt5-qtdeclarative-import-models2
Requires:  qt5-qtdeclarative-import-positioning
Requires:  qt5-qtdeclarative-import-multimedia
Requires:  qt5-qtmultimedia-plugin-mediaservice-gstcamerabin >= 5.1.0+git25
Requires:  qt5-qtmultimedia-plugin-mediaservice-gstmediaplayer
Requires:  declarative-transferengine-qt5 >= 0.0.49
Requires:  nemo-qml-plugin-thumbnailer-qt5-video
Requires:  nemo-qml-plugin-thumbnailer-qt5
Requires:  nemo-qml-plugin-dbus-qt5
Requires:  nemo-qml-plugin-policy-qt5
Requires:  nemo-qml-plugin-time-qt5
Requires:  nemo-qml-plugin-configuration-qt5
Requires:  nemo-qml-plugin-notifications-qt5 >= 1.1.2
Requires:  sailfish-content-graphics-default-base >= 0.7.47
Requires:  sailfish-components-media-qt5 >= 0.0.18
Requires:  sailfish-components-gallery-qt5 >= 0.0.48
Requires:  libjollasignonuiservice-qt5-plugin >= 0.0.29
Requires:  libngf-qt5-declarative
Requires:  ambienced
Requires:  jolla-theme >= 0.9.2
Requires:  gstreamer1.0-plugins-good
Requires:  gstreamer1.0-plugins-bad
Requires:  dconf
Requires:  qt5-qtdeclarative-systeminfo
Requires:  %{name}-lockscreen = %{version}
Requires:  %{name}-settings = %{version}
%{_oneshot_requires_post}

%description
The Jolla Camera application.

%package ts-devel
Summary:   Translation source for Jolla Camera
Group:     Applications/Multimedia

%description ts-devel
Translation source for Jolla Camera

%package lockscreen
Summary:   Quick capture viewfinder for the lockscreen.
Group:     System/Applications
Requires:   %{name} = %{version}-%{release}

%description lockscreen
%{summary}

%package settings
Summary:   Setting page for jolla-camera
Group:     System/Applications
Requires:   %{name} = %{version}-%{release}
Requires:  jolla-settings
Requires:  jolla-settings-system >= 0.11.37
Requires:  sailfish-policy

%description settings
%{summary}

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
%{_datadir}/applications/jolla-camera.desktop
%{_datadir}/applications/jolla-camera-viewfinder.desktop
%{_datadir}/jolla-camera/camera.qml
%{_datadir}/jolla-camera/pages/*
%{_datadir}/jolla-camera/cover/*
%{_bindir}/jolla-camera
%{_datadir}/translations/jolla-camera_eng_en.qm
%{_datadir}/dbus-1/services/com.jolla.camera.service
%{_libdir}/qt5/qml/com/jolla/camera/libjollacameraplugin.so
%{_libdir}/qt5/qml/com/jolla/camera/capture/*
%{_libdir}/qt5/qml/com/jolla/camera/qmldir
%{_libdir}/qt5/qml/com/jolla/camera/DisabledByMdmView.qml
%{_libdir}/qt5/qml/com/jolla/camera/settings/*
%{_libdir}/qt5/qml/com/jolla/camera/settings.qml
%{_sysconfdir}/dconf/db/vendor.d/jolla-camera.txt
%{_oneshotdir}/camera-enable-hints
%{_oneshotdir}/camera-remove-deprecated-dconfkeys

%files ts-devel
%defattr(-,root,root,-)
%{_datadir}/translations/source/jolla-camera.ts

%files lockscreen
%{_bindir}/jolla-camera-lockscreen
%{_datadir}/applications/jolla-camera-lockscreen.desktop
%{_datadir}/jolla-camera/lockscreen.qml

%files settings
%{_datadir}/jolla-settings/*

%files tests
%defattr(-,root,root,-)
# >> files tests
/opt/tests/jolla-camera/*
# << files tests

%post
%{_bindir}/add-oneshot dconf-update

if [ "$1" -eq 2 ]; then
%{_bindir}/add-oneshot --user camera-remove-deprecated-dconfkeys
fi

if [ "$1" -eq 1 ]; then
%{_bindir}/add-oneshot --user --now camera-enable-hints
fi


