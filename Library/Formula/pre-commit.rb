class PreCommit < Formula
  desc "Framework for managing multi-language pre-commit hooks"
  homepage "http://pre-commit.com/"
  url "https://github.com/pre-commit/pre-commit/archive/v0.5.0.tar.gz"
  sha256 "567d8e0f64e176c2c2c97c80a3c96c2d40c7a21d205bee84ce5f74d9323de9fb"

  bottle do
    cellar :any
    sha256 "04457ca976ceaceab0056ad380ba1e74c3b93d66756f2f7bde2fcfa5e53e7e03" => :yosemite
    sha256 "9d3712f895202a7e13e728b29ba696c81e961a7fb991e988bdc85997bc00679a" => :mavericks
    sha256 "ed2c946573cacdccb0dcf3c59663ba38cc73abbc84da8e722dc726a704977b66" => :mountain_lion
  end

  depends_on :python if MacOS.version <= :snow_leopard

  resource "argparse" do
    url "https://pypi.python.org/packages/source/a/argparse/argparse-1.3.0.tar.gz"
    sha256 "b3a79a23d37b5a02faa550b92cbbbebeb4aa1d77e649c3eb39c19abf5262da04"
  end

  resource "aspy.yaml" do
    url "https://pypi.python.org/packages/source/a/aspy.yaml/aspy.yaml-0.2.1.tar.gz"
    sha256 "a91370183aea63c87d8487e7b399ed2d99a7c2f14b108d27c0bc8ad9ef595d9a"
  end

  resource "cached-property" do
    url "https://pypi.python.org/packages/source/c/cached-property/cached-property-1.2.0.tar.gz"
    sha256 "e3081a8182d3d4b7283eeade76c382bcfd4dfd644ca800598229c2ef798abb53"
  end

  resource "jsonschema" do
    url "https://pypi.python.org/packages/source/j/jsonschema/jsonschema-2.4.0.tar.gz"
    sha256 "1298a2f1b2f4c4a7b921cccd159e4e42f6d7b0fb75c86c0cdecfc71f061833fa"
  end

  resource "nodeenv" do
    url "https://pypi.python.org/packages/source/n/nodeenv/nodeenv-0.13.2.tar.gz"
    sha256 "626881a22f252635fe2bc72b554e1fbb2b80bcd626103de21ed112ea0c024e37"
  end

  resource "ordereddict" do
    url "https://pypi.python.org/packages/source/o/ordereddict/ordereddict-1.1.tar.gz"
    sha256 "1c35b4ac206cef2d24816c89f89cf289dd3d38cf7c449bb3fab7bf6d43f01b1f"
  end

  resource "pyyaml" do
    url "https://pypi.python.org/packages/source/P/PyYAML/PyYAML-3.11.tar.gz"
    sha256 "c36c938a872e5ff494938b33b14aaa156cb439ec67548fcab3535bb78b0846e8"
  end

  resource "simplejson" do
    url "https://pypi.python.org/packages/source/s/simplejson/simplejson-3.7.1.tar.gz"
    sha256 "4b837e37885503776b8d76182aa91e3bb27a3c38a023b14008e4cb63170bebc4"
  end

  resource "virtualenv" do
    url "https://pypi.python.org/packages/source/v/virtualenv/virtualenv-12.1.1.tar.gz"
    sha256 "3c88cf7df114c32cf0651d12f979b8db556d992d647493e5bdbbe2828be40007"
  end

  def install
    ENV["PYTHONPATH"] = libexec/"vendor/lib/python2.7/site-packages"
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"

    resources.each do |r|
      r.stage do
        system "python", *Language::Python.setup_install_args(libexec/"vendor")
      end
    end

    # fix aspy.yaml (because namespace .pth isn't processed)
    touch libexec/"vendor/lib/python2.7/site-packages/aspy/__init__.py"

    system "python", *Language::Python.setup_install_args(libexec)

    bin.install Dir["#{libexec}/bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    testpath.cd do
      system "git", "init"
      (testpath/".pre-commit-config.yaml").write <<-EOF.undent
      -   repo: git://github.com/pre-commit/pre-commit-hooks
          sha: 5541a6a046b7a0feab73a21612ab5d94a6d3f6f0
          hooks:
          -   id: trailing-whitespace
      EOF
      system bin/"pre-commit", "install"
      system bin/"pre-commit", "run", "--all-files"
    end
  end
end
