{ pkgs, ... }:
let
  inherit (pkgs) fetchFromGitHub;
  inherit (pkgs.vimUtils) buildVimPlugin;
in {
  handle-errors-nvim = buildVimPlugin {
    pname = "handle_errors.nvim";
    version = "2024-08-22";
    src = fetchFromGitHub {
      owner = "aaron-p1";
      repo = "handle_errors.nvim";
      rev = "4c2f67b0beabf03c85cbcde05744878c6a24d7d9";
      hash = "sha256-/ejvAvEb2JHfRTgAq8TdK+SZhEuExXNdVsbd059kkjM=";
    };
    buildInputs = [ pkgs.luajit ];
    buildPhase = "make";
    meta.homepage = "https://github.com/aaron-p1/handle_errors.nvim";
    meta.platforms = [ "x86_64-linux" ];
  };
  match-visual-nvim = buildVimPlugin {
    pname = "match-visual.nvim";
    version = "2024-04-29";
    src = fetchFromGitHub {
      owner = "aaron-p1";
      repo = "match-visual.nvim";
      rev = "98540e79c151126187907278ff5bc61823edcebc";
      sha256 = "sha256-wYBueqOcIfqJOFjdSAUHe8725i9dKmwqTxaNWW3gmg4=";
    };
    meta.homepage = "https://github.com/aaron-p1/match-visual.nvim";
  };
  virt-notes-nvim = buildVimPlugin {
    pname = "virt-notes.nvim";
    version = "2023-09-10";
    src = fetchFromGitHub {
      owner = "aaron-p1";
      repo = "virt-notes.nvim";
      rev = "1c43e82cc996e3df570b9d08a305bc7e5135ab0e";
      sha256 = "sha256-I6oygOgFX3Bzy4rJ1MQUebxy+VGLBXJfXPPFsQZzubA=";
    };
    meta.homepage = "https://github.com/aaron-p1/virt-notes.nvim";
  };
  compare-remotes-nvim = buildVimPlugin {
    pname = "compare-remotes.nvim";
    version = "2023-02-15";
    src = fetchFromGitHub {
      owner = "aaron-p1";
      repo = "compare-remotes.nvim";
      rev = "501f6dba3c916204a3bf586d7b4b789a64157aad";
      sha256 = "sha256-mEk8JgOjUp/3FDBu3DgumHqa3+kuT7SjzQLEmEvc42Y=";
    };
    meta.homepage = "https://github.com/aaron-p1/compare-remotes.nvim";
  };
  ts-node-action = buildVimPlugin {
    pname = "ts-node-action";
    version = "2024-05-30";
    src = fetchFromGitHub {
      owner = "CKolkey";
      repo = "ts-node-action";
      rev = "6d3b60754fd87963d70eadaa2f77873b447eac26";
      sha256 = "sha256-kOXH3r+V+DAxoATSnZepEAekrkO1TezKSkONuQ3Kzu4=";
    };
    meta.homepage = "https://github.com/CKolkey/ts-node-action";
    dependencies = [ pkgs.vimPlugins.nvim-treesitter ];
  };
}
