class PodmanCompose < Formula
  include Language::Python::Virtualenv

  desc "Alternative to docker-compose using podman"
  homepage "https://github.com/containers/podman-compose"
  url "https://files.pythonhosted.org/packages/cc/03/da068b60e240b08bc54f177ca6259c33af1b0eefab1d3591a63eec70a250/podman_compose-1.4.1.tar.gz"
  sha256 "fc91801443cae5515ca55e72d6a961ab8524cd5483eec99230c7ac7591b841a9"
  license "GPL-2.0-only"

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "4d9b09c8ca553ed2aa25b5c5f3ef083d9d66f8a603705dae34b56264385a968d"
    sha256 cellar: :any,                 arm64_sonoma:  "55e46b82c6c24c401a5cb922307c325ea1324b61cf2e2ef29fc7433d8b1e801c"
    sha256 cellar: :any,                 arm64_ventura: "4ee7ad6af1c4ac86a5466b36352f65396bdad3e5d6785d9fef193759379a182b"
    sha256 cellar: :any,                 sonoma:        "5c40e3d91bbe2fe40aa323ef2bf2098d19c38f063b27c383d0a9e128e7ff0b10"
    sha256 cellar: :any,                 ventura:       "b121d5e9b4d0c22d3d2b450099807791e8a0de6fe7906fe9f3510480d18c1270"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "0cb67e609ddebca3d553c9061b8a2c989960f13dd2f25da16de611d1d21ebb6d"
  end

  depends_on "libyaml"
  depends_on "podman"
  depends_on "python@3.13"

  resource "python-dotenv" do
    url "https://files.pythonhosted.org/packages/f6/b0/4bc07ccd3572a2f9df7e6782f52b0c6c90dcbb803ac4a167702d7d0dfe1e/python_dotenv-1.1.1.tar.gz"
    sha256 "a8a6399716257f45be6a007360200409fce5cda2661e3dec71d23dc15f6189ab"
  end

  resource "pyyaml" do
    url "https://files.pythonhosted.org/packages/54/ed/79a089b6be93607fa5cdaedf301d7dfb23af5f25c398d5ead2525b063e17/pyyaml-6.0.2.tar.gz"
    sha256 "d584d9ec91ad65861cc08d42e834324ef890a082e591037abe114850ff7bbc3e"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    ENV["COMPOSE_PROJECT_NAME"] = "brewtest"

    port = free_port

    (testpath/"compose.yml").write <<~YAML
      version: "3"
      services:
        test:
          image: nginx:1.22
          ports:
            - #{port}:80
          environment:
            - NGINX_PORT=80
    YAML

    assert_match "podman ps --filter label=io.podman.compose.project=brewtest",
      shell_output("#{bin}/podman-compose up -d 2>&1", 1)
    # If it's trying to connect to Podman, we know it at least found the
    # compose.yml file and parsed/validated the contents
    expected = OS.linux? ? "Error: cannot re-exec process" : "Cannot connect to Podman"
    assert_match expected, shell_output("#{bin}/podman-compose down 2>&1", 1)
  end
end
