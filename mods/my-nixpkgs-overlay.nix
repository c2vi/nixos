
{ nixpkgs, ... }: final: prev: {
		#{
			#localPacketTracer8 = (pkgs.callPackage ../../prebuilt/packetTracer/default.nix {confDir = confDir;});
			#xdg-desktop-portal-termfilechooser = (pkgs.callPackage ../../mods/xdg-desktop-portal-termfilechooser/default.nix {});
			#firefox = inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin;
		#}
    #{
      #supabase-cli = pkgs.callPackage ./supabase.nix;
    #}

  # for static builds
  duktape = prev.duktape.overrideAttrs (innerFinal: innerPrev: {
    patches = innerPrev.patches or [] ++ [
      ./static/duktape.patch
    ];
    #unpackPhase = "echo hiiiiiiiiiiiiiiiiiiiiiiiiiii";
    #buildPhase = "echo hiiiiiiiiiiiiiiiiiiiiiiiiii";

    buildPhase = ''
      make -f dist-files/Makefile.staticlibrary
      make -f Makefile.cmdline
    '';
    installPhase = ''
      install -d $out/bin
      install -m755 duk $out/bin/
      install -d $out/lib/pkgconfig
      install -d $out/include
      make -f dist-files/Makefile.staticlibrary install INSTALL_PREFIX=$out
      substituteAll ${nixpkgs}/pkgs/development/interpreters/duktape/duktape.pc.in $out/lib/pkgconfig/duktape.pc
    '';
  });

  dconf = prev.dconf.overrideAttrs (innerFinal: innerPrev: {
    patches = innerPrev.patches or [] ++ [
      ./static/dconf.patch
    ];
  });

  at-spi2-core = prev.at-spi2-core.overrideAttrs (innerFinal: innerPrev: {
    mesonFlags = innerPrev.mesonFlags or [] ++ [
      "-Dintrospection=disabled"
      "-Ddbus_broker=default"
      "-Dgtk2_atk_adaptor=false"
    ];
  });

  cdparanoia = prev.cdparanoia.overrideAttrs (innerFinal: innerPrev: {
    patches = innerPrev.patches or [] ++ [
      ./static/cdparanoia.patch
    ];
  });


  # this is a mess....
  #pkgsStatic = prev.pkgsStatic // {gobject-introspection = prev.callPackage ./static/gobject-introspection.nix { inherit nixpkgs; };};
  #gobject-introspection = prev.callPackage ./static/gobject-introspection.nix { inherit nixpkgs; };
  #buildPackges = prev.buildPackges // {gobject-introspection = prev.callPackage ./static/gobject-introspection.nix { inherit nixpkgs; };};
  # .... gobject-introspection is just not made for dyn linking

  python311Packages = prev.python311Packages // { lxml = prev.python311Packages.lxml.overrideAttrs (innerFinal: innerPrev: 
    let
      libxmlSrc = prev.fetchurl {
        url = "mirror://gnome/sources/libxml2/${prev.lib.versions.majorMinor "2.12.4"}/libxml2-2.12.4.tar.xz";
        sha256 = "sha256-SXNg5CPPC9merNt8YhXeqS5tbonulAOTwrrg53y5t9A=";
      };
      zlibSrc = let version = "1.3.1"; in prev.fetchurl  {
        urls = [
          # This URL works for 1.2.13 only; hopefully also for future releases.
          "https://github.com/madler/zlib/releases/download/v${version}/zlib-${version}.tar.gz"
          # Stable archive path, but captcha can be encountered, causing hash mismatch.
          "https://www.zlib.net/fossils/zlib-${version}.tar.gz"
        ];
        hash = "sha256-mpOyt9/ax3zrpaVYpYDnRmfdb+3kWFuR7vtg8Dty3yM=";
      };
      libiconvSrc = prev.fetchurl {
        url = "https://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.17.tar.gz";
        hash = "sha256-j3QhO1YjjIWlClMp934GGYdx5w3Zpzl3n0wC9l2XExM=";
      };
      libxsltSrc = let version = "1.1.37"; pname = "libxslt"; in prev.fetchurl {
        url = "mirror://gnome/sources/${pname}/${prev.lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
        sha256 = "Oksn3IAnzNYUZyWVAzbx7FIJKPMg8UTrX6eZCuYSOrQ=";
      };
    in
    {
      setupPyBuildFlags = [
        "--libxml2-version=2.12.4"
        "--libxslt-version=1.1.37"
        "--zlib-version=1.3.1"
        "--libiconv-version=1.17"
        "--without-cython"
      ];
      patches = [
        ./static/python311Packages-lxml.patch
        # built without any extensions ... hardcoded with a patch
      ];

      STATICBUILD = true;
      preConfigure = ''
        mkdir -p ./libs
        cp ${zlibSrc} ./libs/${zlibSrc.name}
        cp ${libiconvSrc} ./libs/${libiconvSrc.name}
        cp ${libxmlSrc} ./libs/${libxmlSrc.name}
        cp ${libxsltSrc} ./libs/${libxsltSrc.name}

        ls ./libs
      '';
        #cat ${libxsltSrc} | xz -d | gzip > ./libs/${libxsltSrc.name}
        #cat ${libxmlSrc} | xz -d | gzip > ./libs/${libxmlSrc.name}
        #mv ./libs/libxslt-1.1.37.tar.xz ./libs/libxslt-1.1.37.tar.gz
        #mv ./libs/libxml2-2.10.4.tar.xz ./libs/libxml2-2.10.4.tar.gz
    });
  };

  pkgsStatic = prev.pkgsStatic // {
    libglvnd = prev.libglvnd;
    gonme2.libIDL = prev.gnome2.libIDL;
    libjpeg-turbe = prev.libjpeg-turbo;
  };


}


