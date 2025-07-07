class ChainloopCli < Formula
  desc "CLI for interacting with Chainloop"
  homepage "https://docs.chainloop.dev"
  url "https://github.com/chainloop-dev/chainloop/archive/refs/tags/v1.20.0.tar.gz"
  sha256 "5b748fd6791f623e871ebd76a51ef2fbf66fecc5e2496e471449e95fb3b07423"
  license "Apache-2.0"
  head "https://github.com/chainloop-dev/chainloop.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "96c297fc695b9e181751652716a8dd53ec4aa098f8f7f0fa0fe22721ed5462c5"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "f905047c895ab5186270b4fb06b9417545fb01aa92317efecf58ecd3eb328cd5"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "541a1fb3170d7a3bf4b0cb98cb75c9fe6b26296269cf6ac250142a7b4e7e8dad"
    sha256 cellar: :any_skip_relocation, sonoma:        "53a17882533245b097669981b085a99b1352bec830fcf5713594e9073b08c184"
    sha256 cellar: :any_skip_relocation, ventura:       "7b6991d1fc5b1e98ac3e6addcf2a21b785469a00cbd71b168865bc2c092fd69d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "1cd3256cb66754245dcf54ad85bbd4ba7fa6b84f1c50ad362125d9f3dab59eef"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/chainloop-dev/chainloop/app/cli/cmd.Version=#{version}
    ]

    system "go", "build", *std_go_args(ldflags:, output: bin/"chainloop"), "./app/cli"

    generate_completions_from_executable(bin/"chainloop", "completion")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/chainloop version 2>&1")

    output = shell_output("#{bin}/chainloop artifact download 2>&1", 1)
    assert_match "authentication required, please run \"chainloop auth login\"", output
  end
end
