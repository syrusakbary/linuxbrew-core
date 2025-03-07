class Cmake < Formula
  desc "Cross-platform make"
  homepage "https://www.cmake.org/"
  url "https://github.com/Kitware/CMake/releases/download/v3.19.5/cmake-3.19.5.tar.gz"
  sha256 "c432296eb5dec6d71eae15d140f6297d63df44e9ffe3e453628d1dc8fc4201ce"
  license "BSD-3-Clause"
  head "https://gitlab.kitware.com/cmake/cmake.git"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "c242c56b2cfc3053a1b277eaa1d5fd6cf1e50c469fd5c5091d9bf7b475bbffb5"
    sha256 cellar: :any_skip_relocation, big_sur:       "a682d329ab579365215c7f409810e10b199df02d8856a760d472d4fb7c30bb42"
    sha256 cellar: :any_skip_relocation, catalina:      "4f33e84c319f1ded3f2c3b26e57c9727b3842b1a44863054c83158203ad52e75"
    sha256 cellar: :any_skip_relocation, mojave:        "375c91283a2b18b80c99b9e93c8344fe9351d39b87927e89449bbcbb1ca2c10b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "0362bb4a6dbc531deb12b2de7650ec2ff9c9d01444e24d9b5caa43bb036fd9ce"
  end

  depends_on "sphinx-doc" => :build
  depends_on "ncurses"

  uses_from_macos "ncurses"

  on_linux do
    depends_on "openssl@1.1"
  end

  # The completions were removed because of problems with system bash

  # The `with-qt` GUI option was removed due to circular dependencies if
  # CMake is built with Qt support and Qt is built with MySQL support as MySQL uses CMake.
  # For the GUI application please instead use `brew install --cask cmake`.

  def install
    on_linux do
      ENV.cxx11
    end

    args = %W[
      --prefix=#{prefix}
      --no-system-libs
      --parallel=#{ENV.make_jobs}
      --datadir=/share/cmake
      --docdir=/share/doc/cmake
      --mandir=/share/man
      --sphinx-build=#{Formula["sphinx-doc"].opt_bin}/sphinx-build
      --sphinx-html
      --sphinx-man
    ]
    on_macos do
      args += %w[
        --system-zlib
        --system-bzip2
        --system-curl
      ]
    end

    system "./bootstrap", *args, "--", *std_cmake_args,
                                       "-DCMake_INSTALL_EMACS_DIR=#{elisp}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"CMakeLists.txt").write("find_package(Ruby)")
    system bin/"cmake", "."
  end
end
