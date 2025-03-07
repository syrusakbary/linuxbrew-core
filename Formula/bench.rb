class Bench < Formula
  desc "Command-line benchmark tool"
  homepage "https://github.com/Gabriel439/bench"
  license "BSD-3-Clause"
  revision 1
  head "https://github.com/Gabriel439/bench.git"

  stable do
    url "https://hackage.haskell.org/package/bench-1.0.12/bench-1.0.12.tar.gz"
    sha256 "a6376f4741588201ab6e5195efb1e9921bc0a899f77a5d9ac84a5db32f3ec9eb"

    # Compatibility with GHC 8.8. Remove with the next release.
    patch do
      url "https://github.com/Gabriel439/bench/commit/846dea7caeb0aee81870898b80345b9d71484f86.patch?full_index=1"
      sha256 "fac63cd1ddb0af3bda78900df3ac5a4e6b6d2bb8a3d4d94c2f55d3f21dc681d1"
    end
  end

  bottle do
    sha256 cellar: :any_skip_relocation, big_sur:      "c9ee5713f0c97785f37506da9e34f4cda353beaad06a5209fce27aeb93e3f770"
    sha256 cellar: :any_skip_relocation, catalina:     "b1eccbf77a04e4de1a59a0eed5c0f6e2d8b6b191736ee9ad4fdea9a173010651"
    sha256 cellar: :any_skip_relocation, mojave:       "493de8888b6fe1745a887cda10a421448a08943496124b1cb49cc02453002638"
    sha256 cellar: :any_skip_relocation, high_sierra:  "cd0e9ae0bc13d3db0330ae839689d9b2d129bc0bf0c1b7165033968a9e6a0f22"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "23f3a716580dbbceca9a43b79afced24b66180ae2abecf25ce6c429363f53354"
  end

  depends_on "cabal-install" => :build
  depends_on "ghc@8.8" => :build

  uses_from_macos "zlib"

  def install
    system "cabal", "v2-update"
    system "cabal", "v2-install", *std_cabal_v2_args
  end

  test do
    assert_match /time\s+[0-9.]+/, shell_output("#{bin}/bench pwd")
  end
end
