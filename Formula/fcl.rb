class Fcl < Formula
  desc "Flexible Collision Library"
  homepage "https://flexible-collision-library.github.io/"
  url "https://github.com/flexible-collision-library/fcl/archive/v0.6.1.tar.gz"
  sha256 "c8a68de8d35a4a5cd563411e7577c0dc2c626aba1eef288cb1ca88561f8d8019"
  license "BSD-3-Clause"
  head "https://github.com/flexible-collision-library/fcl.git"

  bottle do
    sha256 big_sur:      "64e20a01b7a05f081b6b01ebe88722a0afec56514940130c0720e2ee5e5325df"
    sha256 catalina:     "05a5dfa094009376e5915ad14289490fa370462153102eb43e402d50663a23f4"
    sha256 mojave:       "7fc28b6f1bd196e83873f61617e590af68ebf861cfc76af9d892c8ef40b25601"
    sha256 high_sierra:  "625f6117a551777a1f12eba3253886a441a5a00e2759218b9566d40bb9f3ab2c"
    sha256 x86_64_linux: "a4893b2dff93aba4c97dc4a6efa19406b0c276e5491c0ba0a6c1768ad057b986"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "boost"
  depends_on "eigen"
  depends_on "libccd"
  depends_on "octomap"

  def install
    ENV.cxx11
    system "cmake", ".", "-DBUILD_TESTING=OFF", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <fcl/geometry/shape/box.h>
      #include <cassert>

      int main() {
        assert(fcl::Boxd(1, 1, 1).computeVolume() == 1);
      }
    EOS

    system ENV.cxx, "test.cpp", "-std=c++11", "-I#{include}",
                    "-I#{Formula["eigen"].include}/eigen3",
                    "-L#{lib}", "-lfcl", "-o", "test"
    system "./test"
  end
end
