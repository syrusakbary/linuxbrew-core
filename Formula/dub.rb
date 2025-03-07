class Dub < Formula
  desc "Build tool for D projects"
  homepage "https://code.dlang.org/getting_started"
  url "https://github.com/dlang/dub/archive/v1.24.0.tar.gz"
  sha256 "4d14ba97748d89a2af9a3d62c1721c2f92bd393b010a9a4a39037449941e1312"
  license "MIT"
  version_scheme 1
  head "https://github.com/dlang/dub.git"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, big_sur:      "3b754d2403322152227cc45a1525321f64c940143bde42220595dcee4d32361f"
    sha256 cellar: :any_skip_relocation, catalina:     "b71a9aa0abd4e9f25391ab6e25be4357c5a70801c4c2e86332bfc909c5253568"
    sha256 cellar: :any_skip_relocation, mojave:       "acdd545896e27976e2178ea9bf12dba7d39e2118ba04dc762a444f639b51ce81"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "abb46db06450bc7dcc1f65e6bf963c4adaa99fc718a4ef48e739904bfa75886f"
  end

  depends_on "dmd" => :build
  depends_on "pkg-config"

  uses_from_macos "curl"

  def install
    ENV["GITVER"] = version.to_s
    system "./build.d"
    system "bin/dub", "scripts/man/gen_man.d"
    bin.install "bin/dub"
    man1.install Dir["scripts/man/*.1"]
    zsh_completion.install "scripts/zsh-completion/_dub"
    fish_completion.install "scripts/fish-completion/dub.fish"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/dub --version").split(/[ ,]/)[2]
  end
end
