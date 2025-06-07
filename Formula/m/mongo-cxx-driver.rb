class MongoCxxDriver < Formula
  desc "C++ driver for MongoDB"
  homepage "https://github.com/mongodb/mongo-cxx-driver"
  url "https://github.com/mongodb/mongo-cxx-driver/releases/download/r4.0.0/mongo-cxx-driver-r4.0.0.tar.gz"
  sha256 "d8a254bde203d0fe2df14243ef2c3bab7f12381dc9206d0c1b450f6ae02da7cf"
  license "Apache-2.0"
  head "https://github.com/mongodb/mongo-cxx-driver.git", branch: "master"

  livecheck do
    url :stable
    regex(/^[rv]?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    rebuild 1
    sha256 cellar: :any,                 arm64_sequoia: "a5ffe092afce00444e05ee5cdfb8001117477f591d56c903433d29d5ad83cb3f"
    sha256 cellar: :any,                 arm64_sonoma:  "826490125872b68bee63c2d174cee531d80f6df3a4b8c827890247e0e417cfbf"
    sha256 cellar: :any,                 arm64_ventura: "5b05a991ab83a52e323abfbe07e2f0f04409f94099dff5f6ce4ec469183a3455"
    sha256 cellar: :any,                 sonoma:        "d681ae294c7218b31f9ef1a163a668ecffb3a3718dae7fe0a717adc1861a6219"
    sha256 cellar: :any,                 ventura:       "bba38b659f6c7cd906ffb7fafdf938552315cffd4237b7d9ffccb37194cb1551"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "28b2bf9f290e93e18229b958daef29aaa60261c7e3523eb8f1a129ebbc1a0b11"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "86b9e24205688ef528e54cfe31979b92198225fa8d994c35090d0990b72d7cb7"
  end

  depends_on "cmake" => :build
  depends_on "pkgconf" => :test
  depends_on "mongo-c-driver@1"

  def install
    # We want to avoid shims referencing in examples,
    # but we need to have examples/CMakeLists.txt file to make cmake happy
    pkgshare.install "examples"
    (buildpath / "examples/CMakeLists.txt").write ""

    mongo_c_prefix = Formula["mongo-c-driver@1"].opt_prefix
    args = %W[
      -DBUILD_VERSION=#{version}
      -DLIBBSON_DIR=#{mongo_c_prefix}
      -DLIBMONGOC_DIR=#{mongo_c_prefix}
      -DCMAKE_INSTALL_RPATH=#{rpath}
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    pkgconf_flags = shell_output("pkgconf --cflags --libs libbsoncxx").chomp.split
    system ENV.cc, "-std=c++11", pkgshare/"examples/bsoncxx/builder_basic.cpp",
                   "-I#{pkgshare}", *pkgconf_flags, "-lstdc++", "-o", "test"
    system "./test"

    pkgconf_flags = shell_output("pkgconf --cflags --libs libbsoncxx libmongocxx").chomp.split
    system ENV.cc, "-std=c++11", pkgshare/"examples/mongocxx/connect.cpp",
                   "-I#{pkgshare}", *pkgconf_flags, "-lstdc++", "-o", "test"
    assert_match "No suitable servers", shell_output("./test mongodb://0.0.0.0 2>&1", 1)
  end
end
