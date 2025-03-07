class Miller < Formula
  desc "Like sed, awk, cut, join & sort for name-indexed data such as CSV"
  homepage "https://github.com/johnkerl/miller"
  url "https://github.com/johnkerl/miller/releases/download/v5.10.0/mlr-5.10.0.tar.gz"
  sha256 "1e964a97ee0333a57966a2e8d1913aebc28875e9bee3effbbc51506ca5389200"
  license "BSD-2-Clause"
  head "https://github.com/johnkerl/miller.git"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "6549e28916d341df56a77990fdd06aa3120821447d12614e233b60b6019b4343"
    sha256 cellar: :any_skip_relocation, big_sur:       "5b19f1751ba3d39d94c371443583a2fd53b035e93c4ffdd8432e6c978ba43601"
    sha256 cellar: :any_skip_relocation, catalina:      "d806164692bbe7077e28e8deb819c24ab3e7ba0794ffa6073654e54d32538649"
    sha256 cellar: :any_skip_relocation, mojave:        "bceb6b1ff93c9bb4b11a38af1ce4b4c06f3a572e06f0f8132a9b0799a1caa3e3"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "3326d93811656dd823e87c7ef5b66a76a1bb738d40123c643730f7941433a6e4"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  uses_from_macos "flex" => :build

  def install
    # Profiling build fails with Xcode 11, remove it
    inreplace "c/Makefile.am", /noinst_PROGRAMS=\s*mlrg/, ""
    system "autoreconf", "-fvi"

    system "./configure", "--prefix=#{prefix}", "--disable-silent-rules",
                          "--disable-dependency-tracking"
    system "make"
    # Time zone related tests fail. Reported upstream https://github.com/johnkerl/miller/issues/237
    system "make", "check" if !OS.mac? && ENV["HOMEBREW_GITHUB_ACTIONS"]
    system "make", "install"
  end

  test do
    (testpath/"test.csv").write <<~EOS
      a,b,c
      1,2,3
      4,5,6
    EOS
    output = pipe_output("#{bin}/mlr --csvlite cut -f a test.csv")
    assert_match /a\n1\n4\n/, output
  end
end
