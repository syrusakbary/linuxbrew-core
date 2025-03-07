class Sk < Formula
  desc "Fuzzy Finder in rust!"
  homepage "https://github.com/lotabout/skim"
  url "https://github.com/lotabout/skim/archive/v0.9.4.tar.gz"
  sha256 "5ec639c34c7657be4f7f990e9ad0d8d0a7a979eba68daa7c100126ce06702a1b"
  license "MIT"
  head "https://github.com/lotabout/skim.git"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "1bd497fc73a90ccca27cc9bff110d394f65148839c25265d017fc384fddd9c55"
    sha256 cellar: :any_skip_relocation, big_sur:       "61c1157e45e27f80c0aa1807416b82562540d72d6e1132912f59fc9fd0d51c86"
    sha256 cellar: :any_skip_relocation, catalina:      "e1b6019d494e2750d305e5366b51129720126c51931928681da48ba89293a46b"
    sha256 cellar: :any_skip_relocation, mojave:        "05483c56866808ff11d9054ccfde8b7c8bfea652d3aff1f353cddca5e4451d4f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "40ee06fb9558836638afaf272766937ed9d550bcca687588039bf4ecd85bfb8d"
  end

  depends_on "rust" => :build

  def install
    (buildpath/"src/github.com/lotabout").mkpath
    ln_s buildpath, buildpath/"src/github.com/lotabout/skim"
    system "cargo", "install", *std_cargo_args

    pkgshare.install "install"
    bash_completion.install "shell/key-bindings.bash"
    bash_completion.install "shell/completion.bash"
    fish_completion.install "shell/key-bindings.fish" => "skim.fish"
    zsh_completion.install "shell/key-bindings.zsh"
    zsh_completion.install "shell/completion.zsh"
    man1.install "man/man1/sk.1", "man/man1/sk-tmux.1"
    bin.install "bin/sk-tmux"
  end

  test do
    assert_match /.*world/, pipe_output("#{bin}/sk -f wld", "hello\nworld")
  end
end
