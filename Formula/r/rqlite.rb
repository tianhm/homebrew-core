class Rqlite < Formula
  desc "Lightweight, distributed relational database built on SQLite"
  homepage "https://www.rqlite.io/"
  url "https://github.com/rqlite/rqlite/archive/refs/tags/v8.39.0.tar.gz"
  sha256 "b55159a2a1c6707c15f4de7f232af07800545347a3805c89752c1da8078fda4f"
  license "MIT"
  head "https://github.com/rqlite/rqlite.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "e76d7025dce0f0fc2699888b98f679038277b5f55464325e8f0783734ed98fd0"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d889008a3331887d1f2a7b67c5e4e4a123b411e3af316e4a8e8c570b2500a8d2"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "1a99ce8d115c99f9a253851c28e0ac12faa0751403012cf2db196aecc4a2f8ac"
    sha256 cellar: :any_skip_relocation, sonoma:        "7db96640da7c3bede2b1d7dfc1be240f02dd1da71be302dccbbddea4118c86f0"
    sha256 cellar: :any_skip_relocation, ventura:       "963cf1f48724f2b8c24ce63af9c147af512ec78dd84a82ea7ead22131ca67358"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "ce028f18fc49c74c38f281ab5624a84d399201ea86218b20e67f950df49a03ce"
  end

  depends_on "go" => :build

  def install
    version_ldflag_prefix = "-X github.com/rqlite/rqlite/v#{version.major}"
    ldflags = %W[
      -s -w
      #{version_ldflag_prefix}/cmd.Commit=unknown
      #{version_ldflag_prefix}/cmd.Branch=master
      #{version_ldflag_prefix}/cmd.Buildtime=#{time.iso8601}
      #{version_ldflag_prefix}/cmd.Version=v#{version}
    ]
    %w[rqbench rqlite rqlited].each do |cmd|
      system "go", "build", *std_go_args(ldflags:), "-o", bin/cmd, "./cmd/#{cmd}"
    end
  end

  test do
    port = free_port
    fork do
      exec bin/"rqlited", "-http-addr", "localhost:#{port}",
                          "-raft-addr", "localhost:#{free_port}",
                          testpath
    end
    sleep 5

    (testpath/"test.sql").write <<~SQL
      CREATE TABLE foo (id INTEGER NOT NULL PRIMARY KEY, name TEXT)
      .schema
      quit
    SQL
    output = shell_output("#{bin}/rqlite -p #{port} < test.sql")
    assert_match "foo", output

    output = shell_output("#{bin}/rqbench -a localhost:#{port} 'SELECT 1'")
    assert_match "Statements/sec", output

    assert_match "Version v#{version}", shell_output("#{bin}/rqlite -v")
  end
end
