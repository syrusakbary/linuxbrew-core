class XmlSecurityC < Formula
  desc "Implementation of primary security standards for XML"
  homepage "https://santuario.apache.org/"
  url "https://www.apache.org/dyn/closer.lua?path=santuario/c-library/xml-security-c-2.0.2.tar.bz2"
  mirror "https://archive.apache.org/dist/santuario/c-library/xml-security-c-2.0.2.tar.bz2"
  sha256 "39e963ab4da477b7bda058f06db37228664c68fe68902d86e334614dd06e046b"
  license "Apache-2.0"
  revision 1

  bottle do
    sha256 cellar: :any, arm64_big_sur: "5ac142618a6c4f97bd5c1b554a69a9668f36e1b462910d9eaae8b8f3556fcbec"
    sha256 cellar: :any, big_sur:       "ed512d0c411b694e5835b4b33338e9e347ceea4e564a5caeecc9e41e26b5fc53"
    sha256 cellar: :any, catalina:      "ce0f62697cff7004fa7498ebc0dcc917206be09847847fa2ec31285b81ed04ce"
    sha256 cellar: :any, mojave:        "eec2216263c3bb21b52418d18232034aacc69335d3e14624225627fe5364347c"
    sha256 cellar: :any, high_sierra:   "5ee66d19898cd50085e90392313d3a1f45204bd111f32019251af89ee84f1ca5"
    sha256 cellar: :any, sierra:        "bd1e4d4b5768f869d28850ad440e32d417f6db5d182c6049afc87575bb36ccc9"
    sha256 cellar: :any, x86_64_linux:  "3df702bab27cebced62824fd1c0f743102d7b863e77cf45990b1be824f36e389"
  end

  depends_on "pkg-config" => :build
  depends_on "openssl@1.1"
  depends_on "xerces-c"

  def install
    ENV.cxx11

    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking",
                          "--with-openssl=#{Formula["openssl@1.1"].opt_prefix}"
    system "make", "install"
  end

  test do
    assert_match /All tests passed/, pipe_output("#{bin}/xsec-xtest 2>&1")
  end
end
