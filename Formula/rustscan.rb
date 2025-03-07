class Rustscan < Formula
  desc "Modern Day Portscanner"
  homepage "https://github.com/rustscan/rustscan"
  url "https://github.com/RustScan/RustScan/archive/2.0.1.tar.gz"
  sha256 "1d458cb081cbed2db38472ff33f9546a6640632148b4396bd12f0229ca9de7eb"
  license "GPL-3.0-or-later"

  bottle do
    sha256 cellar: :any_skip_relocation, big_sur:      "83c8a3e9b4a71e21590bd377b1db9518cb32794d341d161519e974dd3e837f2e"
    sha256 cellar: :any_skip_relocation, catalina:     "21f4b50689613475ca9194ecae3b062e874d49bb987b1949f453885360715200"
    sha256 cellar: :any_skip_relocation, mojave:       "135ddda8cfa5a670c0c49e3730148e8f50dfa1b597d9bdf2c35b5fc4d5a8fd9e"
    sha256 cellar: :any_skip_relocation, high_sierra:  "d830a6c803a7cd609c6287452f9c02bb855e1f193463b2655cc2df19e46e1f6a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "4b0a7c4a9589907ccd517995757a088d363a6383cb9cdf2fec6d339242494691"
  end

  depends_on "rust" => :build
  depends_on "nmap"

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_no_match /panic/, shell_output("#{bin}/rustscan --greppable -a 127.0.0.1")
    assert_no_match /panic/, shell_output("#{bin}/rustscan --greppable -a 0.0.0.0")
  end
end
