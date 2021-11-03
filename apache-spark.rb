class ApacheSpark < Formula
  desc "Engine for large-scale data processing"
  homepage "https://spark.apache.org/"
  url "https://www.apache.org/dyn/closer.lua?path=spark/spark-2.4.5/spark-2.4.5-bin-without-hadoop.tgz"
  mirror "https://archive.apache.org/dist/spark/spark-2.4.5/spark-2.4.5-bin-without-hadoop.tgz"
  version "2.4.5"
  sha256 "40f58f117efa83a1d0e66030d3561a8d7678f5473d1f3bb53e05c40d8d6e6781"
  head "https://github.com/apache/spark.git"

  depends_on :java => "1.8"
  depends_on "stewi2/homebrew-hadoop/hadoop"

  def install
    # Rename beeline to distinguish it from hive's beeline
    mv "bin/beeline", "bin/spark-beeline"

    rm_f Dir["bin/*.cmd"]
    libexec.install Dir["*"]
    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", Language::Java.java_home_env("1.8"))

    cd libexec do
      cp "conf/spark-env.sh.template", "conf/spark-env.sh"
      # https://spark.apache.org/docs/latest/hadoop-provided.html
      (libexec/"conf/spark-env.sh").append_lines "export SPARK_DIST_CLASSPATH=$(hadoop classpath)"
    end
  end

  test do
    assert_match "Long = 1000",
      pipe_output(bin/"spark-shell --conf spark.driver.bindAddress=127.0.0.1",
                  "sc.parallelize(1 to 1000).count()")
  end
end
