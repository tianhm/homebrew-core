class Monetdb < Formula
  desc "Column-store database"
  homepage "https://www.monetdb.org/"
  url "https://www.monetdb.org/downloads/sources/Mar2025-SP1/MonetDB-11.53.9.tar.xz"
  sha256 "69ae47c7ac0cda295f62622506b227586ce503220bab90296a5435c997f7df2f"
  license "MPL-2.0"
  head "https://www.monetdb.org/hg/MonetDB", using: :hg

  livecheck do
    url "https://www.monetdb.org/downloads/sources/archive/"
    regex(/href=.*?MonetDB[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  no_autobump! because: :requires_manual_review

  bottle do
    sha256 arm64_sequoia: "811dbba2a7a0a49eaa8343b618357acab09643e15964cc87bcf3870a2b75fcbe"
    sha256 arm64_sonoma:  "04607201555000b2ef3d7161c5e04b1c5484f8e664079f6ee13ba4e7ff154812"
    sha256 arm64_ventura: "4086d9b06c5a837fd60091acdd9939af1a7f796c7b48609a4965fedf58f6ee3f"
    sha256 sonoma:        "809158eb2ef11a08330751baa5eadc890d9145070137dd20ad542fefafb8b04e"
    sha256 ventura:       "2d09c0cfab88cd2da92b908eac4b50dabff0a621f7d83d0d72dfa9463121292c"
    sha256 arm64_linux:   "dd20fb9e3d59d86c79488f84d221d34188f4c17d19c2fbd3ed939ac1fef08f41"
    sha256 x86_64_linux:  "c2727126524f1c893ef23ad6fdbd38307c51e40613df9dfeb6fe7e6c2b852514"
  end

  depends_on "bison" => :build # macOS bison is too old
  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "lz4"
  depends_on "openssl@3"
  depends_on "pcre"
  depends_on "readline" # Compilation fails with libedit
  depends_on "xz"

  uses_from_macos "python" => :build
  uses_from_macos "bzip2"
  uses_from_macos "zlib"

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DRELEASE_VERSION=ON",
                    "-DASSERT=OFF",
                    "-DSTRICT=OFF",
                    "-DTESTING=OFF",
                    "-DFITS=OFF",
                    "-DGEOM=OFF",
                    "-DNETCDF=OFF",
                    "-DODBC=OFF",
                    "-DPY3INTEGRATION=OFF",
                    "-DRINTEGRATION=OFF",
                    "-DSHP=OFF",
                    "-DWITH_BZ2=ON",
                    "-DWITH_CMOCKA=OFF",
                    "-DWITH_CURL=ON",
                    "-DWITH_LZ4=ON",
                    "-DWITH_LZMA=ON",
                    "-DWITH_OPENSSL=ON",
                    "-DWITH_PCRE=ON",
                    "-DWITH_PROJ=OFF",
                    "-DWITH_RTREE=OFF",
                    "-DWITH_SQLPARSE=OFF",
                    "-DWITH_VALGRIND=OFF",
                    "-DWITH_XML2=ON",
                    "-DWITH_ZLIB=ON",
                    *std_cmake_args
    # remove reference to shims directory from compilation/linking info
    inreplace "build/tools/mserver/monet_version.c", %r{"/[^ ]*/}, "\""
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    # assert_match "Usage", shell_output("#{bin}/mclient --help 2>&1")
    system bin/"monetdbd", "create", testpath/"dbfarm"
    assert_path_exists testpath/"dbfarm"
  end
end
