class CabalInstall < Formula
  desc "Command-line interface for Cabal and Hackage"
  homepage "https://www.haskell.org/cabal/"
  url "https://hackage.haskell.org/package/cabal-install-3.2.0.0/cabal-install-3.2.0.0.tar.gz"
  sha256 "a0555e895aaf17ca08453fde8b19af96725da8398e027aa43a49c1658a600cb0"
  license "BSD-3-Clause"
  revision 1
  head "https://github.com/haskell/cabal.git", branch: "3.2"

  bottle do
    sha256 cellar: :any_skip_relocation, big_sur:      "e5cf4ef514f88918a5eb50b704b97cd5a335d9112b2458d19ba6ed2520e8da2c"
    sha256 cellar: :any_skip_relocation, catalina:     "28a4d8d675adfd734abf2bc4294a1587caca5bf34c1a8e5dbf5c7bea03d36513"
    sha256 cellar: :any_skip_relocation, mojave:       "e9bdce7d81f4a3135f054da0cf596d23a22b3996f1264614e0a87a21c5b9be55"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e4e4e10f3d229448a52af4ed22284f1c36f5b3152ce6dfca0c97759e5bd0d427"
  end

  # cabal-install 3.2 needs to be bootstrapped with ghc 8.8
  depends_on "ghc@8.8" => :build
  depends_on "ghc"
  uses_from_macos "zlib"

  # Update bootstrap dependencies to work with base-4.13.0.0
  patch :p2 do
    url "https://github.com/haskell/cabal/commit/b6f7ec5f3598f69288bddbdba352e246e337fb90.patch?full_index=1"
    sha256 "f4c869e74968c5892cd1fa1001adf96eddcec73e03fb5cf70d3a0c0de08d9e4e"
  end

  def install
    ENV.prepend_path "PATH", Formula["ghc@8.8"].bin
    cd "cabal-install" if build.head?

    system "sh", "bootstrap.sh", "--sandbox"
    bin.install ".cabal-sandbox/bin/cabal"
    bash_completion.install "bash-completion/cabal"
  end

  test do
    system "#{bin}/cabal", "--config-file=#{testpath}/config", "info", "Cabal"
  end
end
