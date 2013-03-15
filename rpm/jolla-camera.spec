Name:       jolla-camera
Summary:    Jolla Camera application
Version:    0.0.1
Release:    1
Group:      Applications/Multimedia
License:    TBD
URL:        https://bitbucket.org/jolla/ui-jolla-camera
Source0:    %{name}-%{version}.tar.bz2
BuildRequires:  pkgconfig(QtCore) >= 4.8.0
BuildRequires:  pkgconfig(QtDeclarative)
BuildRequires:  pkgconfig(QtGui)
BuildRequires:  pkgconfig(QtOpenGL)
BuildRequires:  pkgconfig(QtNetwork)
BuildRequires:  pkgconfig(QtMultimediaKit)
BuildRequires:  desktop-file-utils
BuildRequires:  pkgconfig(qdeclarative-boostable)

Requires:  ambient-icons-closed
Requires:  sailfishsilica >= 0.8.0
Requires:  mapplauncherd-booster-jolla
Requires:  libdeclarative-multimedia
Requires:  declarative-transferengine => 0.0.12
Requires:  nemo-qml-plugins-accounts
Requires:  nemo-qml-plugins-gstvideo-thumbnailer
Requires:  nemo-qml-plugins-thumbnailer
Requires:  jolla-gallery-facebook
Requires:  jollacomponents-internal

%description
The Jolla Camera application.

%package ts-devel
Summary:   Translation source for Jolla Camera
License:   TBD
Group:     Applications/Multimedia

%description ts-devel
Translation source for Jolla Camera

%package tests
Summary:    Unit tests for Jolla Camera
Group:      Applications/Multimedia
BuildRequires:  pkgconfig(QtTest)
BuildRequires:  pkgconfig(QtMultimediaKit)
Requires:   %{name} = %{version}-%{release}
Requires:   qtest-qml

%description tests
This package contains QML unit tests for Jolla Camera application

%prep
%setup -q -n %{name}-%{version}

%build

%qmake %{name}.pro

make %{?jobs:-j%jobs}

%install
rm -rf %{buildroot}
%qmake_install
chmod +x %{buildroot}/opt/tests/jolla-camera/auto/run-tests.sh

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_datadir}/applications/*.desktop
%{_datadir}/jolla-camera/*
%{_bindir}/jolla-camera
%{_datadir}/translations/jolla-camera_eng_en.qm

%files ts-devel
%defattr(-,root,root,-)
%{_datadir}/translations/source/jolla-camera.ts

%files tests
%defattr(-,root,root,-)
# >> files tests
/opt/tests/jolla-camera/*
# << files tests

%post -n jolla-camera -p /sbin/ldconfig
%postun -n jolla-camera -p /sbin/ldconfig


