class Armadillo < Formula
  desc "C++ linear algebra library"
  homepage "https://arma.sourceforge.io/"
  url "https://downloads.sourceforge.net/project/arma/armadillo-10.2.1.tar.xz"
  sha256 "7d8e74d248769af23fc894d8bb88f05e32317933cbe4da8f3c56be8f89a9fcc4"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(%r{url=.*?/armadillo[._-]v?(\d+(?:\.\d+)+)\.t}i)
  end

  bottle do
    sha256 cellar: :any,                 arm64_big_sur: "5312473d19474df4ba766f11794f6d2d41295d277970a76b55e195798705fa6b"
    sha256 cellar: :any,                 big_sur:       "4c75a9b4d57b2259fd30e018355786eaa5fd38aa690d968e988e33bd449f3fd5"
    sha256 cellar: :any,                 catalina:      "77d6bbd45875e3d44f96c5fb53c86569ac057f8c4d5885ff65ba25aa53552fd6"
    sha256 cellar: :any,                 mojave:        "d1a5ea00a11331b68db7d28b60fee70c7138ca4333871c9a1e48f903fd67d237"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "9dddad8431b5f250f5932b95be25026491820d7c344bad831df622d4f8d90033"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "arpack"
  depends_on "hdf5"
  depends_on "openblas"
  depends_on "superlu"
  depends_on "szip"

  def install
    ENV.prepend "CXXFLAGS", "-DH5_USE_110_API -DH5Ovisit_vers=1"

    system "cmake", ".", "-DDETECT_HDF5=ON", "-DALLOW_OPENBLAS_MACOS=ON", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <iostream>
      #include <armadillo>

      int main(int argc, char** argv) {
        std::cout << arma::arma_version::as_string() << std::endl;
      }
    EOS
    system ENV.cxx, "-std=c++11", "test.cpp", "-I#{include}", "-L#{lib}", "-larmadillo", "-o", "test"
    assert_equal shell_output("./test").to_i, version.to_s.to_i
  end
end
