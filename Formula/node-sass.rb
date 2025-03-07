class NodeSass < Formula
  require "language/node"

  desc "JavaScript implementation of a Sass compiler"
  homepage "https://github.com/sass/dart-sass"
  url "https://registry.npmjs.org/sass/-/sass-1.32.7.tgz"
  sha256 "77c6a2f921abf30b980b77d544a17892ba51f011988162a64180f4a92abcee39"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "64765519ac0f3904b45c305f522e86c5e07ffeccb0f216b74b848fd09e5fda15"
    sha256 cellar: :any_skip_relocation, big_sur:       "96ea70a195e6802e11c9bdcb4ff6e6241e7b9384d18866063fbe8a9bf0b707e2"
    sha256 cellar: :any_skip_relocation, catalina:      "f7b8dadc5234661a87a37aaee064fa618f387077b203f58cd60382da7df71bc3"
    sha256 cellar: :any_skip_relocation, mojave:        "e4c7f238199c0df1aba0be33f1e5363d8ab12adfe6bcbc424d5e3c19d14b923b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "bda109e0b0c88f71451d7836897afd57c99b065e68adeaf6cfba109d99522519"
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/"test.scss").write <<~EOS
      div {
        img {
          border: 0px;
        }
      }
    EOS

    assert_equal "div img{border:0px}",
    shell_output("#{bin}/sass --style=compressed test.scss").strip
  end
end
