{ final, prev, ... }:
let zprev = prev.zathuraPkgs;
in prev.zathuraPkgs // rec {
  zathura_pdf_mupdf = zprev.zathura_pdf_mupdf.overrideAttrs
    (old: { patches = (old.patches or [ ]) ++ [ ./mupdf.patch ]; });

  zathuraWrapper = zprev.zathuraWrapper.override {
    plugins = [
      zprev.zathura_djvu
      zprev.zathura_ps
      zprev.zathura_cb
      zathura_pdf_mupdf
    ];
  };
}
