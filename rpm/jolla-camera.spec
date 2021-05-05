Name:       jolla-camera
Summary:    Jolla Camera application
Version:    1.0.24
Release:    1
License:    Proprietary
URL:        https://bitbucket.org/jolla/ui-jolla-camera
Source0:    %{name}-%{version}.tar.bz2
Source1:    %{name}.privileges
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
Requires:  sailfishsilica-qt5 >= 1.1.79
Requires:  qt5-qtdeclarative-import-models2
Requires:  qt5-qtdeclarative-import-positioning
Requires:  qt5-qtdeclarative-import-multimedia
Requires:  qt5-qtdeclarative-import-sensors
Requires:  qt5-qtmultimedia-plugin-mediaservice-gstcamerabin >= 5.6.2+git25
Requires:  qt5-qtmultimedia-plugin-mediaservice-gstmediaplayer
Requires:  declarative-transferengine-qt5 >= 0.0.49
Requires:  nemo-qml-plugin-thumbnailer-qt5-video
Requires:  nemo-qml-plugin-thumbnailer-qt5
Requires:  nemo-qml-plugin-dbus-qt5
Requires:  nemo-qml-plugin-policy-qt5
Requires:  nemo-qml-plugin-time-qt5
Requires:  nemo-qml-plugin-configuration-qt5
Requires:  nemo-qml-plugin-notifications-qt5 >= 1.1.2
Requires:  nemo-qml-plugin-systemsettings >= 0.5.21
Requires:  libkeepalive >= 1.7.0
Requires:  sailfish-components-media-qt5 >= 0.0.18
Requires:  sailfish-components-gallery-qt5 >= 1.1.10
Requires:  sailfish-policy >= 0.2.59
Requires:  jolla-settings-system >= 1.0.70
Requires:  libjollasignonuiservice-qt5-plugin >= 0.0.29
Requires:  libngf-qt5-declarative
Requires:  qr-filter-qml-plugin
Requires:  ambienced
Requires:  sailfish-content-graphics
Requires:  gstreamer1.0-plugins-good
Requires:  gstreamer1.0-plugins-bad
Requires:  dconf
Requires:  %{name}-lockscreen = %{version}
Requires:  %{name}-settings = %{version}
Requires:  sailjail-launch-approval
%{_oneshot_requires_post}

%description
The Jolla Camera application.

%package ts-devel
Summary:   Translation source for Jolla Camera

%description ts-devel
Translation source for Jolla Camera.

%package lockscreen
Summary:   Quick capture viewfinder for the lockscreen.
Requires:   %{name} = %{version}-%{release}

%description lockscreen
%{summary}.

%package settings
Summary:   Setting page for jolla-camera
Requires:   %{name} = %{version}-%{release}
Requires:  jolla-settings
Requires:  jolla-settings-system >= 0.11.37
Requires:  sailfish-policy

%description settings
%{summary}.

%package tests
Summary:    Unit tests for Jolla Camera
BuildRequires:  pkgconfig(Qt5Test)
BuildRequires:  pkgconfig(Qt5Multimedia)
Requires:   %{name} = %{version}-%{release}
Requires:   qt5-qtdeclarative-import-qttest
Requires:   qt5-qtdeclarative-devel-tools

%description tests
This package contains QML unit tests for Jolla Camera application.

%prep
%setup -q -n %{name}-%{version}

%build

%qmake5 %{name}.pro

make %{?_smp_mflags}

%install
rm -rf %{buildroot}
%qmake5_install
chmod +x %{buildroot}/opt/tests/jolla-camera/auto/run-tests.sh

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop
chmod +x %{buildroot}/%{_oneshotdir}/*

mkdir -p %{buildroot}%{_datadir}/mapplauncherd/privileges.d
install -m 644 -p %{SOURCE1} %{buildroot}%{_datadir}/mapplauncherd/privileges.d/

%files
%defattr(-,root,root,-)
%{_datadir}/applications/jolla-camera.desktop
%{_datadir}/applications/jolla-camera-viewfinder.desktop
# Define directory ownership explicitly as part of files in the datadir
# belongs to jolla-camera-lockscreen.
%dir %{_datadir}/jolla-camera
%{_datadir}/jolla-camera/camera.qml
%{_datadir}/jolla-camera/pages
%{_datadir}/jolla-camera/cover
%{_datadir}/mapplauncherd/privileges.d/*
%{_bindir}/jolla-camera
%{_datadir}/translations/jolla-camera_eng_en.qm
%{_datadir}/dbus-1/services/com.jolla.camera.service
%{_libdir}/qt5/qml/com/jolla/camera
%{_sysconfdir}/dconf/db/vendor.d/jolla-camera.txt
%{_oneshotdir}/camera-enable-hints

%files ts-devel
%defattr(-,root,root,-)
%{_datadir}/translations/source/jolla-camera.ts

%files lockscreen
%{_bindir}/jolla-camera-lockscreen
%{_datadir}/applications/jolla-camera-lockscreen.desktop
%{_datadir}/jolla-camera/lockscreen.qml
%{_datadir}/jolla-camera/LockedGalleryView.qml

%files settings
%{_datadir}/jolla-settings

%files tests
%defattr(-,root,root,-)
/opt/tests/jolla-camera

%post
%{_bindir}/add-oneshot dconf-update || :
%{_bindir}/add-oneshot --new-users camera-enable-hints || :
