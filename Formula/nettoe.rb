class Nettoe < Formula
  desc "Tic Tac Toe-like game for the console"
  homepage "https://nettoe.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/nettoe/nettoe/1.5.1/nettoe-1.5.1.tar.gz"
  sha256 "dbc2c08e7e0f7e60236954ee19a165a350ab3e0bcbbe085ecd687f39253881cb"
  license "GPL-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "a9f2e1b0a27c15f903c42fd54af41f52553d9027cde5aff110e7f8a895b934a8"
    sha256 cellar: :any_skip_relocation, big_sur:       "2387ff01457bbf7019cff906e9503de1b7cc718f055abd3eaa9523b847d951a5"
    sha256 cellar: :any_skip_relocation, catalina:      "59cab1291f69cb1c35a269d18343a3d07eaf55d6f0d178c9548afb282497fc50"
    sha256 cellar: :any_skip_relocation, mojave:        "2d45bfae915cfc4425e45393a9868c4e586379c05e61f35aaf704cc54376c17c"
    sha256 cellar: :any_skip_relocation, high_sierra:   "0349c1335e428d5f0b620043259908b5af60feed84d9dea911033e0d65704488"
    sha256 cellar: :any_skip_relocation, sierra:        "49ad705043bdd9f1ab860d877d3ffba584bef5ddbd4c03f6fe43adc49b9c1e5d"
    sha256 cellar: :any_skip_relocation, el_capitan:    "c8208683e4730233147e6c7153a469cdc1f477aacde0559937f0da93c8ad0345"
    sha256 cellar: :any_skip_relocation, yosemite:      "78038d253cd382f5f3a6b3b12c7776828c44c1572f0569bec862763aa5141c2a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "8e1c49404519fb92debf74026248900db5e369039f7326052e665456840ed15c"
  end

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    assert_match /netToe #{version} /, shell_output("#{bin}/nettoe -v")
  end
end
