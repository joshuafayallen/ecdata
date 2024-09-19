

.onLoad = \(libname,pkgname){

  rlang::check_installed(
    pkg = "arrow (>= 16.1.0)",
    reason = "To read in the the ECD data files we need to install arrow."
  )


}