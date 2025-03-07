class DockerLs < Formula
  desc "Tools for browsing and manipulating docker registries"
  homepage "https://github.com/mayflower/docker-ls"
  url "https://github.com/mayflower/docker-ls.git",
      tag:      "v0.5.1",
      revision: "ae0856513066feff2ee6269efa5d665145709d2e"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "146371ff787d25857ec030cb07025e9e7e062b4fba43eb59136aad8ceca57790"
    sha256 cellar: :any_skip_relocation, big_sur:       "69d17d15d79bfa1813ad39ae3a0250ddd919a36b4d3923412cfbc17be56316dc"
    sha256 cellar: :any_skip_relocation, catalina:      "47231e20bcc919d92de35c537c87c54f52bbcdaa85cf2bb9b27bc03a69f25587"
    sha256 cellar: :any_skip_relocation, mojave:        "38eb334f22797271ae8e121030133f6fc3e33cd178cd938940d4ead6565e0225"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "fecad48f19a8ca8da681a4ff2b949aeed78710c92d72e2f72936e11148435df4"
  end

  depends_on "go" => :build

  def install
    system "go", "generate", "./lib"

    %w[docker-ls docker-rm].each do |name|
      system "go", "build", "-trimpath", "-o", bin/name, "-ldflags", "-s -w", "./cli/#{name}"
    end
  end

  test do
    assert_match /\Wlatest\W/m, pipe_output("#{bin}/docker-ls tags \
      -r https://index.docker.io -u '' -p '' \
      --progress-indicator=false library/busybox \
    ")

    assert_match /401/, pipe_output("#{bin}/docker-rm  \
      -r https://index.docker.io -u foo -p bar library/busybox:latest 2<&1 \
    ")
  end
end
