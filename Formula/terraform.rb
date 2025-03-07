class Terraform < Formula
  desc "Tool to build, change, and version infrastructure"
  homepage "https://www.terraform.io/"
  url "https://github.com/hashicorp/terraform/archive/v0.14.6.tar.gz"
  sha256 "84b10f2944a5074b3d42fe1c378f2228cb9451691edf46a7870706d5a8b2749c"
  license "MPL-2.0"
  head "https://github.com/hashicorp/terraform.git"

  livecheck do
    url "https://releases.hashicorp.com/terraform/"
    regex(%r{href=.*?v?(\d+(?:\.\d+)+)/?["' >]}i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, big_sur:      "6446eb93efb888829c3caf132d38db708677aa1935bdc1e7d88647074356d749"
    sha256 cellar: :any_skip_relocation, catalina:     "5b0551abbe64d6fc0798247023c76fa652a1af4d1eb5e12c92b66fe627b2e112"
    sha256 cellar: :any_skip_relocation, mojave:       "bb2c245a511798421f0f6b2e81f3bb3019689cf0b874b22f73e5ce79162be52e"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "dd2854a6543be8a4e2e1a91caf4071dd0c84b470d27e0edebd7072b00d2f8734"
  end

  depends_on "go" => :build

  conflicts_with "tfenv", because: "tfenv symlinks terraform binaries"

  def install
    # v0.6.12 - source contains tests which fail if these environment variables are set locally.
    ENV.delete "AWS_ACCESS_KEY"
    ENV.delete "AWS_SECRET_KEY"

    # resolves issues fetching providers while on a VPN that uses /etc/resolv.conf
    # https://github.com/hashicorp/terraform/issues/26532#issuecomment-720570774
    ENV["CGO_ENABLED"] = "1"

    system "go", "build", *std_go_args, "-ldflags", "-s -w"
  end

  test do
    minimal = testpath/"minimal.tf"
    minimal.write <<~EOS
      variable "aws_region" {
        default = "us-west-2"
      }

      variable "aws_amis" {
        default = {
          eu-west-1 = "ami-b1cf19c6"
          us-east-1 = "ami-de7ab6b6"
          us-west-1 = "ami-3f75767a"
          us-west-2 = "ami-21f78e11"
        }
      }

      # Specify the provider and access details
      provider "aws" {
        access_key = "this_is_a_fake_access"
        secret_key = "this_is_a_fake_secret"
        region     = var.aws_region
      }

      resource "aws_instance" "web" {
        instance_type = "m1.small"
        ami           = var.aws_amis[var.aws_region]
        count         = 4
      }
    EOS
    system "#{bin}/terraform", "init"
    system "#{bin}/terraform", "graph"
  end
end
