class Kapacitor < Formula
  desc "Open source time series data processor"
  homepage "https://github.com/influxdata/kapacitor"
  url "https://github.com/influxdata/kapacitor.git",
      tag:      "v1.5.8",
      revision: "873d93b7377bf1c7bfbcd508e4ea6a6213997aff"
  license "MIT"
  head "https://github.com/influxdata/kapacitor.git"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "53a4ffb90955abd638c370b605249e59cebf063a9bab2a91f8cd78f5ae81542c"
    sha256 cellar: :any_skip_relocation, big_sur:       "a1381a3e165a2aeaac47206ab1de2898de021b1e6508253fdc04d57afe599d6a"
    sha256 cellar: :any_skip_relocation, catalina:      "6e5902e6a5524d6062185bc20eaedaccf68d48ff9a12e374fce7d7666e0b8ad7"
    sha256 cellar: :any_skip_relocation, mojave:        "786f624493214d9b7135f4e01753cab017eb5db0f24a0629319f6c85101755f0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7ca0efc1519cb4ad0137d5bd7bc104b194842506f499b5547b9677c85c133444"
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    kapacitor_path = buildpath/"src/github.com/influxdata/kapacitor"
    kapacitor_path.install Dir["*"]

    cd kapacitor_path do
      system "go", "install",
             "-ldflags", "-X main.version=#{version} -X main.commit=#{Utils.git_head}",
             "./cmd/..."
    end

    inreplace kapacitor_path/"etc/kapacitor/kapacitor.conf" do |s|
      s.gsub! "/var/lib/kapacitor", "#{var}/kapacitor"
      s.gsub! "/var/log/kapacitor", "#{var}/log"
    end

    bin.install "bin/kapacitord"
    bin.install "bin/kapacitor"
    etc.install kapacitor_path/"etc/kapacitor/kapacitor.conf" => "kapacitor.conf"

    (var/"kapacitor/replay").mkpath
    (var/"kapacitor/tasks").mkpath
  end

  plist_options manual: "kapacitord -config #{HOMEBREW_PREFIX}/etc/kapacitor.conf"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>KeepAlive</key>
          <dict>
            <key>SuccessfulExit</key>
            <false/>
          </dict>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>ProgramArguments</key>
          <array>
            <string>#{opt_bin}/kapacitord</string>
            <string>-config</string>
            <string>#{HOMEBREW_PREFIX}/etc/kapacitor.conf</string>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>WorkingDirectory</key>
          <string>#{var}</string>
          <key>StandardErrorPath</key>
          <string>#{var}/log/kapacitor.log</string>
          <key>StandardOutPath</key>
          <string>#{var}/log/kapacitor.log</string>
        </dict>
      </plist>
    EOS
  end

  test do
    (testpath/"config.toml").write shell_output("#{bin}/kapacitord config")

    inreplace testpath/"config.toml" do |s|
      s.gsub! /disable-subscriptions = false/, "disable-subscriptions = true"
      s.gsub! %r{data_dir = "/.*/.kapacitor"}, "data_dir = \"#{testpath}/kapacitor\""
      s.gsub! %r{/.*/.kapacitor/replay}, "#{testpath}/kapacitor/replay"
      s.gsub! %r{/.*/.kapacitor/tasks}, "#{testpath}/kapacitor/tasks"
      s.gsub! %r{/.*/.kapacitor/kapacitor.db}, "#{testpath}/kapacitor/kapacitor.db"
    end

    begin
      pid = fork do
        exec "#{bin}/kapacitord -config #{testpath}/config.toml"
      end
      sleep 2
      shell_output("#{bin}/kapacitor list tasks")
    ensure
      Process.kill("SIGINT", pid)
      Process.wait(pid)
    end
  end
end
