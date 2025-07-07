class FabricAi < Formula
  desc "Open-source framework for augmenting humans using AI"
  homepage "https://danielmiessler.com/p/fabric-origin-story"
  url "https://github.com/danielmiessler/fabric/archive/refs/tags/v1.4.238.tar.gz"
  sha256 "a1e4b437ccd6e595e55bca4594f9ffb4765841ec8a547e4884eba958aadbb449"
  license "MIT"
  head "https://github.com/danielmiessler/fabric.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "8f13cca01cbec03019eeade416543749d0a5005db504f450c0e1c6fbaba007a4"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "8f13cca01cbec03019eeade416543749d0a5005db504f450c0e1c6fbaba007a4"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "8f13cca01cbec03019eeade416543749d0a5005db504f450c0e1c6fbaba007a4"
    sha256 cellar: :any_skip_relocation, sonoma:        "d76d7afa4b6900f1dfbd7245eae378361765abad0a211bf8e1cd868c2f323bc7"
    sha256 cellar: :any_skip_relocation, ventura:       "d76d7afa4b6900f1dfbd7245eae378361765abad0a211bf8e1cd868c2f323bc7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "445fd716fb1bae0abc08bf786ddc378cdfc34f1867cd5e186624b59271e00b4a"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w")
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/fabric-ai --version")

    (testpath/".config/fabric/.env").write("t\n")
    output = shell_output("#{bin}/fabric-ai --dry-run < /dev/null 2>&1")
    assert_match "error loading .env file: unexpected character", output
  end
end
