class MesalibGlw < Formula
  desc "Open-source implementation of the OpenGL specification"
  homepage "https://www.mesa3d.org"
  url "https://mesa.freedesktop.org/archive/glw/glw-8.0.0.tar.bz2"
  sha256 "2da1d06e825f073dcbad264aec7b45c649100e5bcde688ac3035b34c8dbc8597"
  license :cannot_represent
  revision 1

  bottle do
    sha256 cellar: :any,                 arm64_big_sur: "fed357436c36aa832c46cad896d75a9b3f0015658732af9cad3a18b19769ea72"
    sha256 cellar: :any,                 big_sur:       "9580a442aa0843b284317be696caa8742165a1574d20e8398c9fadbdfc426dc6"
    sha256 cellar: :any,                 catalina:      "1a1690918045f775ea6d71216a5b674b5762556aeaf0285e70533150aa7f14b6"
    sha256 cellar: :any,                 mojave:        "39c625451d18574ed9b9fcd6383c3a3e3b0ac7633f85d28df97a3594ea02e37a"
    sha256 cellar: :any,                 high_sierra:   "fdd89421a230f4b3ea4c2b73cae82cd37d3b44bc61afd5b9e7274dc23491dc8b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "ad2d40cdb9d3b725ae8f32e79002079021a99620030d212e2f410e7dc514c1a6"
  end

  depends_on "pkg-config" => :build
  depends_on "libx11"
  depends_on "libxt"
  depends_on "mesa"

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}"

    system "make", "install"
  end
end
