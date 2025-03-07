class Superlu < Formula
  desc "Solve large, sparse nonsymmetric systems of equations"
  homepage "https://portal.nersc.gov/project/sparse/superlu/"
  url "https://portal.nersc.gov/project/sparse/superlu/superlu_5.2.2.tar.gz"
  sha256 "470334a72ba637578e34057f46948495e601a5988a602604f5576367e606a28c"
  license "BSD-3-Clause-LBNL"
  revision 1 unless OS.mac?

  livecheck do
    url :homepage
    regex(/href=.*?superlu[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "5f1c2e676ff4ef640635472b8b8f975c1a0b0c753069add54f1a1f3b838ca769"
    sha256 cellar: :any_skip_relocation, big_sur:       "62393851b2e93277e5420852f6a40ce680fb3d606620984731395024e708a2cc"
    sha256 cellar: :any_skip_relocation, catalina:      "5cc18b04209b3d65f7b1c44413db97251c3bf2933d3a82e9783e269bb21e3d1b"
    sha256 cellar: :any_skip_relocation, mojave:        "84070217c8d262573eacc0d5e5b08ac7e19c68574d0cc229863b6f9d0615d404"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4b9cb0f403bb2ea83ba26501a0376fc423b6865b4cb134d536223231dad01b28"
  end

  depends_on "cmake" => :build
  depends_on "gcc"
  depends_on "openblas"

  def install
    args = std_cmake_args + %W[
      -Denable_internal_blaslib=NO
      -DTPL_BLAS_LIBRARIES=#{Formula["openblas"].opt_lib}/#{shared_library("libopenblas")}
    ]

    on_linux do
      args << "-DBUILD_SHARED_LIBS=YES"
    end

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      system "make", "install"
    end

    # Source and data for test
    pkgshare.install "EXAMPLE/dlinsol.c"
    pkgshare.install "EXAMPLE/g20.rua"
  end

  test do
    system ENV.cc, pkgshare/"dlinsol.c", "-o", "test",
                   "-I#{include}/superlu", "-L#{lib}", "-lsuperlu",
                   "-L#{Formula["openblas"].opt_lib}", "-lopenblas"
    assert_match "No of nonzeros in L+U = 11886",
                 shell_output("./test < #{pkgshare}/g20.rua")
  end
end
