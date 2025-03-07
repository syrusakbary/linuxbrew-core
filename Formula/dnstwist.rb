class Dnstwist < Formula
  include Language::Python::Virtualenv

  desc "Test domains for typo squatting, phishing and corporate espionage"
  homepage "https://github.com/elceef/dnstwist"
  url "https://files.pythonhosted.org/packages/22/8e/3838df4046bb1ad3101a2bc6cb10012efb9c8a4bedce61efecf423296cdc/dnstwist-20201228.tar.gz"
  sha256 "22a1a93c83092ab77d1e71cbddaad0654e12a955f0827525c9d51540538c10e9"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any,                 arm64_big_sur: "4629cbb678e58f68e70750ae9bbd7cf3ff5e133ab40291e1159d1174e48d55ef"
    sha256 cellar: :any,                 big_sur:       "3d6e28eb3ec27b0c5e519aefa31e88a3d0f3818dd24ee50677c3926120c49299"
    sha256 cellar: :any,                 catalina:      "a635f0cacdbd797e1cf6d62b0dc885790c9c0efb09d00158a790cc62eb7821c6"
    sha256 cellar: :any,                 mojave:        "eac085a3319af5d90fef8a6fb2d495d3511b30da0ab118f6e9140b8093fa756c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "2e2c008e85e86c82fede0077d46b55eddf678a64baf0911f7992f168998bc862"
  end

  depends_on "geoip"
  depends_on "python@3.9"
  depends_on "ssdeep"

  uses_from_macos "libffi"

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/06/a9/cd1fd8ee13f73a4d4f491ee219deeeae20afefa914dfb4c130cfc9dc397a/certifi-2020.12.5.tar.gz"
    sha256 "1a4995114262bffbc2413b159f2a1a480c969de6e6eb13ee966d470af86af59c"
  end

  resource "chardet" do
    url "https://files.pythonhosted.org/packages/ee/2d/9cdc2b527e127b4c9db64b86647d567985940ac3698eeabc7ffaccb4ea61/chardet-4.0.0.tar.gz"
    sha256 "0d6f53a15db4120f2b08c94f11e7d93d2c911ee118b6b30a04ec3ee8310179fa"
  end

  resource "dnspython" do
    url "https://files.pythonhosted.org/packages/67/d0/639a9b5273103a18c5c68a7a9fc02b01cffa3403e72d553acec444f85d5b/dnspython-2.0.0.zip"
    sha256 "044af09374469c3a39eeea1a146e8cac27daec951f1f1f157b1962fc7cb9d1b7"
  end

  resource "GeoIP" do
    url "https://files.pythonhosted.org/packages/f2/7b/a463b7c3df8ef4b9c92906da29ddc9e464d4045f00c475ad31cdb9a97aae/GeoIP-1.3.2.tar.gz"
    sha256 "a890da6a21574050692198f14b07aa4268a01371278dfc24f71cd9bc87ebf0e6"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/ea/b7/e0e3c1c467636186c39925827be42f16fee389dc404ac29e930e9136be70/idna-2.10.tar.gz"
    sha256 "b307872f855b18632ce0c21c5e45be78c0ea7ae4c15c828c20788b26921eb3f6"
  end

  resource "ppdeep" do
    url "https://files.pythonhosted.org/packages/64/ad/ca722788606970d227b1778c158d4a04ffd8190487fa80b3273e3fa587ac/ppdeep-20200505.tar.gz"
    sha256 "acc74bb902e6d21b03d39aed740597093c6562185bfe06da9b5272e01c80a1ff"
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/6b/47/c14abc08432ab22dc18b9892252efaf005ab44066de871e72a38d6af464b/requests-2.25.1.tar.gz"
    sha256 "27973dd4a904a4f13b263a19c866c13b92a39ed1c964655f025f3f8d3d75b804"
  end

  resource "tld" do
    url "https://files.pythonhosted.org/packages/b2/86/ac77ffb3032391a77c6c15c0a06b8ab862481ee83adbf2125421c08cb11b/tld-0.12.3.tar.gz"
    sha256 "1959d0db03b7644f5528748f348d5eecdcd27120a8bb4ef00d932b1b1acdf13d"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/29/e6/d1a1d78c439cad688757b70f26c50a53332167c364edb0134cadd280e234/urllib3-1.26.2.tar.gz"
    sha256 "19188f96923873c92ccb987120ec4acaa12f0461fa9ce5d3d0772bc965a39e08"
  end

  resource "whois" do
    url "https://files.pythonhosted.org/packages/40/f0/d2e038bd54a8c95a4240a322682accd4cb2a1d5f298c40aed9e881d63641/whois-0.9.7.tar.gz"
    sha256 "1e0348c6cc763e1a7c87d32ce877e2531096928e477fdb2e100aa3783e2b4279"
  end

  def install
    ENV.append "CPPFLAGS", "-I#{MacOS.sdk_path_if_needed}/usr/include/ffi"

    venv = virtualenv_create(libexec, Formula["python@3.9"].opt_bin/"python3")
    venv.pip_install resources

    (libexec/"bin").install "dnstwist.py" => "dnstwist"
    (bin/"dnstwist").write_env_script libexec/"bin/dnstwist", PATH: "#{libexec}/bin:$PATH"
  end

  test do
    output = shell_output("#{bin}/dnstwist -rsw --thread=1 brew.sh")

    assert_match version.to_s, output
    assert_match "Fetching content from:", output
    assert_match "//brew.sh", output
    assert_match /Processing \d+ permutations/, output
    assert_not_match /notice: missing module/, output
  end
end
