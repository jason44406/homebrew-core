class Sbt < Formula
  desc "Build tool for Scala projects"
  homepage "https://www.scala-sbt.org/"
  url "https://github.com/sbt/sbt/releases/download/v1.3.10/sbt-1.3.10.tgz"
  mirror "https://sbt-downloads.cdnedge.bluemix.net/releases/v1.3.10/sbt-1.3.10.tgz"
  sha256 "3060065764193651aa3fe860a17ff8ea9afc1e90a3f9570f0584f2d516c34380"

  bottle :unneeded

  depends_on "openjdk"

  def install
    inreplace "bin/sbt" do |s|
      s.gsub! 'etc_sbt_opts_file="/etc/sbt/sbtopts"', "etc_sbt_opts_file=\"#{etc}/sbtopts\""
      s.gsub! "/etc/sbt/sbtopts", "#{etc}/sbtopts"
    end

    libexec.install "bin", "lib"
    etc.install "conf/sbtopts"

    (bin/"sbt").write <<~EOS
      #!/bin/sh
      if [ -f "$HOME/.sbtconfig" ]; then
        echo "Use of ~/.sbtconfig is deprecated, please migrate global settings to #{etc}/sbtopts" >&2
        . "$HOME/.sbtconfig"
      fi
      export JAVA_HOME="${JAVA_HOME:-#{Formula["openjdk"].opt_prefix}}"
      exec "#{libexec}/bin/sbt" "$@"
    EOS
  end

  def caveats
    <<~EOS
      You can use $SBT_OPTS to pass additional JVM options to sbt.
      Project specific options should be placed in .sbtopts in the root of your project.
      Global settings should be placed in #{etc}/sbtopts
    EOS
  end

  test do
    ENV.append "_JAVA_OPTIONS", "-Dsbt.log.noformat=true"
    system "#{bin}/sbt", "about"
    assert_match "[info] #{version}", shell_output("#{bin}/sbt sbtVersion")
  end
end
