{
  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      rev = "d2b8b928655f1b5e80985e49555aef70818a9bdf";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }: {
    defaultPackage.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.stdenv.mkDerivation {
      name = "st";
      src = self;
      nativeBuildInputs = with nixpkgs.legacyPackages.x86_64-linux; [ pkgconfig ncurses ];
      buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [ xorg.libX11 xorg.libXft harfbuzz ];
      installFlags = [ "DESTDIR=$(out)" "PREFIX=/" ];
    };
  };
}
