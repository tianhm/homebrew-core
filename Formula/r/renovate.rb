class Renovate < Formula
  desc "Automated dependency updates. Flexible so you don't need to be"
  homepage "https://github.com/renovatebot/renovate"
  url "https://registry.npmjs.org/renovate/-/renovate-40.28.0.tgz"
  sha256 "1cf2b50d1016c210d725478db69a84f8993cf4671821338474b081c264104de7"
  license "AGPL-3.0-only"

  # There are thousands of renovate releases on npm and the page the `Npm`
  # strategy checks is several MB in size and can time out before the request
  # resolves. This checks the first page of tags on GitHub (to minimize data
  # transfer).
  livecheck do
    url "https://github.com/renovatebot/renovate/tags"
    regex(%r{href=["']?[^"' >]*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
    strategy :page_match
    throttle 10
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "62a576d1caa4418ac5e3267f0ff6d7a389b5cbfc284e99331b77fdc50c2b3361"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "2c06529dcf82bf1b916101da0527317aba092a650eccf3667324896cedabef92"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "53ad8bd881845e47881d5cc533c44a8d12d21be5b335c3347953588ea35bdda0"
    sha256 cellar: :any_skip_relocation, sonoma:        "03b0e52990ad6fa99ddb9ce8738d1c918e64afbd66f41093f2149b25cf4de6b6"
    sha256 cellar: :any_skip_relocation, ventura:       "8405e31c16934798e93eb255f4ce449b055303355e484541d94f869e07dda976"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "5da95b8d9d248878288836072eb4ceb01a626c3d6550c4d7b1aa78560a2450ac"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4983597e3e645c1a54a6c52c1891ca7f42f9d4ecf23f4f2dd7f7531874f5df1e"
  end

  depends_on "node@22"

  uses_from_macos "git", since: :monterey

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    system bin/"renovate", "--platform=local", "--enabled=false"
  end
end
