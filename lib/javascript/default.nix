{
  nix-lib,
  shell-lib,
}: {
  mkJsSource = import ./js-source.nix;
  mkNodeModules = import ./node-modules.nix;
  mkJsCheck = import ./check.nix;
  mkTypecheck = import ./typecheck.nix;
  mkEslint = import ./eslint.nix nix-lib;
  mkPrettier = import ./prettier.nix nix-lib;
  mkOxlint = import ./oxlint.nix;
  mkStylelint = import ./stylelint.nix;
  mkKnip = import ./knip.nix;
  mkLinguiCheck = import ./lingui-check.nix;
  mkVitest = import ./vitest.nix shell-lib;
  mkPlaywright = import ./playwright.nix shell-lib;
  mkViteBuild = import ./vite-build.nix;
  mkSizeLimit = import ./size-limit.nix;
  mkSbom = import ./sbom.nix;
}
