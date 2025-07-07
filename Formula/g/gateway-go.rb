class GatewayGo < Formula
  desc "GateWay Client for OpenIoTHub"
  homepage "https://github.com/OpenIoTHub"
  url "https://github.com/OpenIoTHub/gateway-go/archive/refs/tags/v2.0.2.tar.gz"
  sha256 "3cd1ccc97c5ee1a0e039ee5b4f9054718c8da64861f3086e24d98e076f1b7bbc"
  license "MIT"
  head "https://github.com/OpenIoTHub/gateway-go.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "0fe5f86afc791f42a21e4a0dbb5f4e375721e04c5dd5355a43ad7fe5d3d30f6b"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "e87355296003863877b09253547447cc62b9e12f020385bcb48c9ba2b1af29ae"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "47dcbd4f5ea3b2718089724d0c7bc99130a68fd4eeecfd2f3df72b22588cc1b8"
    sha256 cellar: :any_skip_relocation, sonoma:        "f55c8080fe09a5df11ae5e5967b06ac97021d12bc447e3df07737461b2ba366e"
    sha256 cellar: :any_skip_relocation, ventura:       "f47c5b20abe30e372dfcd20aa6b7bfd4ebe721ddd84dd4820a8c9c49b4f3dccd"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "74c938897fb81cd85ca72930bd4de0e4478bb9d89067b4d06e9b530d42e2c377"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/OpenIoTHub/gateway-go/v2/info.Version=#{version}
      -X github.com/OpenIoTHub/gateway-go/v2/info.Commit=
      -X github.com/OpenIoTHub/gateway-go/v2/info.Date=#{Time.now.iso8601}
      -X github.com/OpenIoTHub/gateway-go/v2/info.BuiltBy=#{tap.user}
    ]
    system "go", "build", *std_go_args(ldflags:)
    (etc/"gateway-go").install "gateway-go.yaml"
  end

  service do
    run [opt_bin/"gateway-go", "-c", etc/"gateway-go.yaml"]
    keep_alive true
    error_log_path var/"log/gateway-go.log"
    log_path var/"log/gateway-go.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gateway-go -v 2>&1")
    assert_match "config created", shell_output("#{bin}/gateway-go init --config=gateway.yml 2>&1")
    assert_path_exists testpath/"gateway.yml"
  end
end
