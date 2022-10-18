{ python3Packages, fetchFromGitHub }:
python3Packages.buildPythonApplication rec {
  pname = "create-project";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "aaron-p1";
    repo = "create-project";
    rev = version;
    sha256 = "sha256-QRvFacHYIlUtC/U6O4/oq1TVzf2uHz+piJBCibmJf2U=";
  };

  propagatedBuildInputs = with python3Packages; [ pyyaml inquirer ];
}
