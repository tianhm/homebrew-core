class SyslogNg < Formula
  include Language::Python::Virtualenv

  desc "Log daemon with advanced processing pipeline and a wide range of I/O methods"
  homepage "https://www.syslog-ng.com"
  url "https://github.com/syslog-ng/syslog-ng/releases/download/syslog-ng-4.8.3/syslog-ng-4.8.3.tar.gz"
  sha256 "f82732a8e639373037d2b69c0e6d5d6594290f0350350f7a146af4cd8ab9e2c7"
  license all_of: ["LGPL-2.1-or-later", "GPL-2.0-or-later"]
  head "https://github.com/syslog-ng/syslog-ng.git", branch: "master"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    rebuild 1
    sha256 arm64_sequoia: "fb12c6475377e3398a005a1f759e4a18a792aec01807651f148d8ef8d8414532"
    sha256 arm64_sonoma:  "2c3616f8a0cc849f30b3eb236918b85f9001e768cb86a66127999ec710f20fec"
    sha256 arm64_ventura: "bb5729fca289d1bcd23cf422ffb5a517204101d96ff3ef61f85dc05c0e20cd68"
    sha256 sonoma:        "a64ad470bf2f657329c2619b230c90325dc722999e00ec071ffb96af9bdec821"
    sha256 ventura:       "e54f8e1cf02af58b6f4fd33bf7514c32129c698d678e10245fbbfc5571348cbf"
    sha256 arm64_linux:   "3d979e20f8124d44f6fc4b7896b1ae9eb093c823a061747f7a0f2e0431331422"
    sha256 x86_64_linux:  "5c8567a1fdbe03ab3bf493437dce3854114339fe7f8f6321d8633fbb3a03eb42"
  end

  depends_on "pkgconf" => :build

  depends_on "abseil"
  depends_on "glib"
  depends_on "grpc"
  depends_on "hiredis"
  depends_on "ivykis"
  depends_on "json-c"
  depends_on "libdbi"
  depends_on "libmaxminddb"
  depends_on "libnet"
  depends_on "libpaho-mqtt"
  depends_on "librdkafka"
  depends_on "mongo-c-driver@1"
  depends_on "net-snmp"
  depends_on "openssl@3"
  depends_on "pcre2"
  depends_on "protobuf"
  depends_on "python@3.12"
  depends_on "rabbitmq-c"
  depends_on "riemann-client"

  uses_from_macos "curl"

  on_macos do
    depends_on "gettext"
  end

  def install
    ENV["VERSION"] = version

    python3 = "python3.12"
    venv = virtualenv_create(libexec, python3)
    # FIXME: we should use resource blocks but there is no upstream pip support besides this requirements.txt
    # https://github.com/syslog-ng/syslog-ng/blob/master/requirements.txt
    args = std_pip_args(prefix: false, build_isolation: true).reject { |s| s["--no-deps"] }
    system python3, "-m", "pip", "--python=#{venv.root}/bin/python",
                          "install", *args, "--requirement=#{buildpath}/requirements.txt"

    system "./configure", *std_configure_args,
                          "CXXFLAGS=-std=c++17",
                          "--disable-silent-rules",
                          "--enable-all-modules",
                          "--sysconfdir=#{pkgetc}",
                          "--localstatedir=#{var/name}",
                          "--with-ivykis=system",
                          "--with-python=#{Language::Python.major_minor_version python3}",
                          "--with-python-venv-dir=#{venv.root}",
                          "--disable-example-modules",
                          "--disable-java",
                          "--disable-java-modules",
                          "--disable-smtp"
    system "make", "install"
  end

  test do
    output = shell_output("#{sbin}/syslog-ng --version")
    assert_equal "syslog-ng #{version.major} (#{version})", output.lines.first.chomp
    system sbin/"syslog-ng", "--cfgfile=#{pkgetc}/syslog-ng.conf", "--syntax-only"
  end
end
