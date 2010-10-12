#!/bin/sh
#
# This file creates a w32 binary release
#
VERSION=1.01
DDIR="`pwd`/Enigma-$VERSION"
SDIR=..
BDIR=..
DLLDEFAULTS="SDL SDL_image SDL_mixer SDL_ttf jpeg zlib1 libfreetype-6 libpng12-0 mikmod"

if [ "$ENIGMADEVDLLS" != "" ]; then
  DLLS=$ENIGMADEVDLLS
else
  DLLS=$DLLDEFAULTS
fi

STRIP=/Users/michi/android/ndk-crystax/build/prebuilt/darwin-x86/arm-eabi-4.4.0/bin/arm-eabi-strip
if [ "$STRIP" = "" ]; then
  STRIP=strip
fi

if [ "$ENIGMADEVCROSSPREFIX" != "" ]; then
  PATH="$ENIGMADEVCROSSPREFIX/bin:$PATH"
fi

# copy text file with newline convertion if necessary
function cptext {
    $NLCVT dos2unix $SDIR/$1 >$DDIR/$2 2> /dev/null
    if test $? -ne 0; then
        $NLCVT unix2dos $SDIR/$1 >$DDIR/$2
    else
        cp $SDIR/$1 $DDIR/$2
    fi
}

function cpfile {
	cp $SDIR/$1 $DDIR/$2
}

function cpbuiltfile {
	cp $BDIR/$1 $DDIR/$2
}

# copy files of an extention with newline convertion to lf if necessary
function cplffiles {
    for f in `(cd $SDIR/$1 && ls *.$3)`; do
        $NLCVT dos2unix $SDIR/$1/$f >$DDIR/$2/$f 2> /dev/null
        if test $? -ne 0; then
            cp $SDIR/$1/$f $DDIR/$2/$f
        fi
    done
}

#
# Copy levels
#
function copy_levels
{
    echo "... copying levels"
    mkdir $DDIR/data/levels
    cp -p $SDIR/data/levels/*.png $DDIR/data/levels
    cplffiles data/levels data/levels lua
    cplffiles data/levels data/levels txt
    cplffiles data/levels data/levels xml
    for folder in `(cd $SDIR/data/levels && ls -F)| grep / | grep -v CVS`; do 
	mkdir $DDIR/data/levels/$folder; 
	cp -p $SDIR/data/levels/$folder/*.png $DDIR/data/levels/$folder
        cplffiles data/levels/$folder data/levels/$folder lua
        cplffiles data/levels/$folder data/levels/$folder txt
        cplffiles data/levels/$folder data/levels/$folder xml
    done
}

function copy_data
{
    echo "... copying data files"
    mkdir $DDIR/data
    cplffiles data data lua
    cplffiles data data xml
    for folder in `(cd $SDIR && ls -F data)| grep / | grep gfx`; do 
	mkdir $DDIR/data/$folder; 
	cp -p $SDIR/data/$folder/*.{png,jpg} $DDIR/data/$folder
    done
    mkdir $DDIR/data/schemas
    cplffiles data/schemas data/schemas xsd
    cplffiles data/schemas data/schemas xml
    copy_levels
    mkdir $DDIR/data/fonts
    cp -p $SDIR/data/fonts/*.{bmf,png,txt,ttf} $DDIR/data/fonts
    mkdir $DDIR/data/sound
    cp -p $SDIR/data/sound/*.{ogg,s3m} $DDIR/data/sound
    mkdir $DDIR/data/soundsets 
    mkdir $DDIR/data/soundsets/enigma 
    cp -p $SDIR/data/soundsets/enigma/*.wav $DDIR/data/soundsets/enigma
    mkdir $DDIR/data/thumbs
    cp -p $SDIR/data/thumbs/README $DDIR/data/thumbs
    
    echo "... copying locales:"
    mkdir $DDIR/data/locale
    for lang in de fr nl it es sv ru hu pt fi; do
    	echo "$lang.gmo"
	mkdir "$DDIR/data/locale/$lang"
	mkdir "$DDIR/data/locale/$lang/LC_MESSAGES"
    	cp -p $SDIR/po/$lang.gmo $DDIR/data/locale/$lang/LC_MESSAGES/enigma.mo
    done
}

#
# Copy documentation files
#
function copy_doc
{
    echo "... copying documentation"
    mkdir $DDIR/images $DDIR/images/flags25x15
    cptext README                       README
    cptext COPYING                      COPYING
    cptext CHANGES                      CHANGES
    cptext ACKNOWLEDGEMENTS 		ACKNOWLEDGEMENTS
    cptext doc/index.html 		index.html
    cptext doc/gpl.txt   		gpl.txt
    cptext doc/lgpl.txt 		lgpl.txt
    cptext doc/images/enigma.css	images/enigma.css
    cpfile doc/images/nav_enigma.gif	images/
    cpfile doc/images/nav_cornerul.gif	images/
    cpfile doc/images/nav_cornerur.gif	images/
    cpfile doc/images/favicon.png	images/
    cpfile doc/images/menu_bg.jpg	images/
    cpfile doc/images/flags25x15/*.png	images/flags25x15
    cptext etc/README-SDL.txt 	        README-SDL.txt
    cptext doc/reference/ant_lua.txt 	reference/ant_lua.txt
    cptext doc/reference/sounds.txt	reference/sounds.txt
    cptext doc/reference/soundset.lua   reference/soundset.lua
    cpfile doc/reference/lua2xml	reference/
    cpfile doc/reference/xml2lua	reference/
}

#
# Copy user manual
#
function copy_manual
{
    echo "... copying user manual"
    mkdir $DDIR/manual $DDIR/manual/images
    cpfile doc/manual/images/*.png manual/images
    cpbuiltfile doc/manual/*.html manual
}

#
# Copy reference manual
#
function copy_refman
{
    echo "... copying reference manual"
    mkdir $DDIR/reference $DDIR/reference/images
    cpfile doc/reference/images/*.png reference/images
    cpbuiltfile doc/reference/*.html reference
}

#
# Copy windows DLLs
#
function copy_dlls
{
    echo "... copying DLLs: $DLLS"
    for f in $DLLS; do
        ff="$f.dll"
        if [ -f $ff ]; then
            cp $ff $DDIR/
	else
	    echo "*** DLL missing: $ff ***"
	fi
    done
}

################
# Build Enigma #
################
(cd .. ; make all) >/dev/null

echo "----------------------------------------------------------------"
echo "                 Building Enigma-$VERSION.zip"
echo "----------------------------------------------------------------"


###############
# Find programs
###############

UPX=`which upx`
STRIPFULLPATH=`which $STRIP`
NLCVT="perl $SDIR/etc/nlcvt.pl"

if [ ! ${UPX} ]; then
  echo "*** Program not found: upx" 
  UPX="echo"
fi

if [ ! ${STRIPFULLPATH} ]; then
  echo "*** Program not found: strip"
  STRIP="echo"
fi

###################
# Copy everything #
###################
rm -rf $DDIR
mkdir $DDIR

copy_data
copy_manual
copy_refman
copy_doc

cp $BDIR/etc/enigma.nsi $DDIR/enigma.nsi
cp $BDIR/etc/enigma-inst-lang.nsh $DDIR/enigma-inst-lang.nsh
cp $BDIR/etc/enigma-inst-opt.ini $DDIR/enigma-inst-opt.ini
cp $BDIR/etc/enigma-inst-welcome.bmp $DDIR/enigma-inst-welcome.bmp
cp -p $BDIR/src/enigma.exe $DDIR/enigma.exe

copy_dlls
$STRIP "$DDIR/enigma.exe"
$UPX $DDIR/enigma.exe >/dev/null

rm -f Enigma-w32-$VERSION.zip
zip -r Enigma-w32-$VERSION.zip "Enigma-$VERSION" >/dev/null
rm -rf $DDIR

echo "----------------------------------------------------------------"
echo "                           DONE"
echo "----------------------------------------------------------------"
