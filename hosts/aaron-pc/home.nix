{ ... }: {
  within = {
    git.signingKey = "59B8E3B68C81571F!";
    ssh.keyFiles =
      [ "~/.ssh/id_ed25519_sk" "~/.ssh/id_ed25519_sk_2" "~/.ssh/id_ed25519" ];
  };
}
