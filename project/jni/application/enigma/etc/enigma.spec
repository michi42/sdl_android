#########################################################################
Name: enigma
Version: 1.01
Release: 1
Summary: clone of the ATARI game Oxyd
Group: X11/Games/Strategy
Copyright: GPL
URL: http://www.nongnu.org/enigma/
Buildroot: %{_tmppath}/%{name}-root
Prefix: /usr
Packager: Daniel Heck <dheck@gmx.de>
Source: enigma-%{version}.tar.gz

%description
Enigma is a unique puzzle game, with influences from almost every game
genre.  Your objective is easily explained: you control a small black
marble with your mouse and have to find and uncover all pairs of
identical Oxyd stones in each landscape.  Simple? Yes.  Easy? It would
be, if it weren't for hidden traps, vast mazes, insurmountable
obstacles and innumerable puzzles blocking your direct way to the Oxyd
stones... If you like puzzle games and have a steady hand, Enigma's
more than 500 levels will probably keep you busy for hours on end.

#########################################################################
%clean
case "$RPM_BUILD_ROOT" in *-root) rm -rf $RPM_BUILD_ROOT ;; esac

%prep 
%setup 

%build
./configure --prefix=%{prefix} --enable-optimize
make

%install
case "$RPM_BUILD_ROOT" in *-root) rm -rf $RPM_BUILD_ROOT ;; esac
make install \
	prefix=$RPM_BUILD_ROOT%{prefix}

#########################################################################
%files
%defattr(-,root,root)
%doc README AUTHORS CHANGES COPYING INSTALL 
# %doc doc/HACKING doc/functions.html doc/functions.css
# %doc doc/manual/* doc/manual/images/*
%{prefix}/share/enigma
%{prefix}/bin/enigma
%doc %{prefix}/man/man?/enigma.*

# %changelog
# * Initial specfile by Achim Settelmeier <settel@sirlab.de>
# Not updated and tested for 1.00 release!
