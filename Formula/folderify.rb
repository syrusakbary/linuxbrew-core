class Folderify < Formula
  include Language::Python::Virtualenv

  desc "Generate pixel-perfect macOS folder icons in the native style"
  homepage "https://github.com/lgarron/folderify"
  url "https://files.pythonhosted.org/packages/3d/91/962faecac858237d3d4b194f73ab426bc52878615b11dee7b35ac98b6b19/folderify-2.2.2.tar.gz"
  sha256 "2ce000ffccbb58585213bb477bf25da1f0b9b0a85ed8289baefff5d7041f7043"
  license "MIT"
  # Default branch is "main" not "master"
  head "https://github.com/lgarron/folderify.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "5f9594b7165df5b95eafc0223d0d9f9b3dff3a860baf8c33c1aab317c201de8c"
    sha256 cellar: :any_skip_relocation, big_sur:       "d696700f70a57671ce601395027ba95fba79d07b948f541609dbb5608092a1d6"
    sha256 cellar: :any_skip_relocation, catalina:      "1ba1ac5ff80182cb53b794e98e74dc93327569e26ee64b58a40a9ec4dfe9fa73"
    sha256 cellar: :any_skip_relocation, mojave:        "51fae77b3fd9de3091ee7cca85bebe4f8f388613bcc7adc5d4410242dd2e6f0e"
  end

  depends_on "imagemagick"
  depends_on :macos # needs `iconutil`
  depends_on "python@3.9"

  def install
    virtualenv_install_with_resources
  end

  test do
    # Copies an example icon
    cp("#{libexec}/lib/python3.9/site-packages/folderify/GenericFolderIcon.Yosemite.iconset/icon_16x16.png",
    "icon.png")
    # folderify applies the test icon to a folder
    system "folderify", "icon.png", testpath.to_s
    # Tests for the presence of the file icon
    assert_predicate testpath / "Icon\r", :exist?
  end
end
