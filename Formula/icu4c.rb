class Icu4c < Formula
  desc "C/C++ and Java libraries for Unicode and globalization"
  homepage "http://site.icu-project.org/home"
  url "https://github.com/unicode-org/icu/releases/download/release-67-1/icu4c-67_1-src.tgz"
  version "67.1"
  sha256 "94a80cd6f251a53bd2a997f6f1b5ac6653fe791dfab66e1eb0227740fb86d5dc"
  license "ICU"
  revision 1 unless OS.mac?

  livecheck do
    url :stable
    regex(/^release[._-]v?(\d+(?:[.-]\d+)+)$/i)
    strategy :git do |tags, regex|
      tags.map { |tag| tag[regex, 1]&.gsub("-", ".") }.compact
    end
  end

  bottle do
    sha256 cellar: :any,                 arm64_big_sur: "28603c8d1cc113f70ad4042548f8f6585606025b48d315958236531e8f8d8550"
    sha256 cellar: :any,                 big_sur:       "114cce72e22c5eb713f56b9f91a076b2f2d5930152d3638a95c6decee511aa3e"
    sha256 cellar: :any,                 catalina:      "2d1e91b5127f66e7941790c004817c94c892725c88f84f1e4c37297fcbc0c72f"
    sha256 cellar: :any,                 mojave:        "b6069459c78f18045ee922ce5cb5b235d4b479597d79c3c298d09e0de3d70794"
    sha256 cellar: :any,                 high_sierra:   "0720bd47f020d5ca895ae79eb61623ed3c7de0d4c4f221613105f47147aec01f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7655b72baf9e5c4c8631b7548a53c885e4211b0ee8f183d7a95d4c1cccfa0fa3"
  end

  keg_only :provided_by_macos, "macOS provides libicucore.dylib (but nothing else)"

  # fix C++14 compatibility of U_ASSERT macro.
  # Remove with next release (ICU 68).
  patch :p2 do
    url "https://github.com/unicode-org/icu/commit/715d254a02b0b22681cb6f861b0921ae668fa7d6.patch?full_index=1"
    sha256 "a87e1b9626ec5803b1220489c0d6cc544a5f293f1c5280e3b27871780c4ecde8"
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-samples
      --disable-tests
      --enable-static
      --with-library-bits=64
    ]

    cd "source" do
      system "./configure", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    if File.readable? "/usr/share/dict/words"
      system "#{bin}/gendict", "--uchars", "/usr/share/dict/words", "dict"
    else
      (testpath/"hello").write "hello\nworld\n"
      system "#{bin}/gendict", "--uchars", "hello", "dict"
    end
  end
end
