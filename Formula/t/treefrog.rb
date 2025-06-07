class Treefrog < Formula
  desc "High-speed C++ MVC Framework for Web Application"
  homepage "https://www.treefrogframework.org/"
  url "https://github.com/treefrogframework/treefrog-framework/archive/refs/tags/v2.11.0.tar.gz"
  sha256 "67cbd3d2ee9810007feb97694c6eb1f7ddf9040210e69ca3adc7995c96f63df9"
  license "BSD-3-Clause"
  head "https://github.com/treefrogframework/treefrog-framework.git", branch: "master"

  livecheck do
    url :head
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    rebuild 1
    sha256 arm64_sonoma:  "f2825d2ef758a6cce393ddaced7e37ae897e877a86ce82b548dffbb927cb807e"
    sha256 arm64_ventura: "4da1bedaf0b5cf8d0a1f2110364135c5e64e6b6deaf47f304c0fac3c157a7a8b"
    sha256 sonoma:        "c4311133c3732ccb18444b67bbcffea4057fa335b6c0ebe0770f437a6bd3fd07"
    sha256 ventura:       "b135ece7a7e0c032d7ee9d2f67def883db2a9bfe5692a13e40b3201832339911"
    sha256 x86_64_linux:  "86f4c5dfc21a7914dd2df54ed293ad06a667da0bab9920a1779a31debc2ae291"
  end

  depends_on "pkgconf" => :build
  depends_on "glog"
  depends_on "lz4"
  depends_on "mongo-c-driver@1"
  depends_on "qt"

  def install
    rm_r("3rdparty")
    # Skip unneeded CMake check
    inreplace "configure", "if ! which cmake ", "if false "

    system "./configure", "--prefix=#{prefix}",
                          "--enable-shared-glog",
                          "--enable-shared-lz4",
                          "--enable-shared-mongoc"
    system "make", "-C", "src", "install"
    system "make", "-C", "tools", "install"
  end

  test do
    ENV.delete "CPATH"
    system bin/"tspawn", "new", "hello"
    assert_path_exists testpath/"hello"
    cd "hello" do
      assert_path_exists Pathname.pwd/"hello.pro"

      system Formula["qt"].opt_bin/"qmake"
      assert_path_exists Pathname.pwd/"Makefile"
      system "make"
      system bin/"treefrog", "-v"
    end
  end
end
