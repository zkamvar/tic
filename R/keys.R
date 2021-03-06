#' Get public RSA key
#'
#' Extracts the public key from a public-private key pair
#' generated by [openssl::rsa_keygen()].
#' This key can be installed as a deploy key for a GitHub repository.
#'
#' @param key RSA key, as returned by `openssl::rsa_keygen()`
#' @keywords internal
#' @export
get_public_key <- function(key) {
  as.list(key)$pubkey
}

#' Encode a private RSA key
#'
#' Extracts the private key from a public-private key pair
#' generated by [openssl::rsa_keygen()], and encodes it in
#' base64 encoding.
#' This key can be stored in the `id_rsa` private environment variable on Travis CI,
#' from where [step_install_ssh_keys()] will pick it up to provide the CI process
#' with deployment rights.
#'
#' @inheritParams get_public_key
#' @seealso [step_install_ssh_keys()] [step_test_ssh()] [step_setup_ssh()]
#' @keywords internal
#' @export
encode_private_key <- function(key) {
  if (!requireNamespace("openssl", quietly = FALSE)) {
    stopc("Please install the openssl package.")
  }

  conn <- textConnection(NULL, "w")
  openssl::write_pem(key, conn, password = NULL)
  private_key <- textConnectionValue(conn)
  close(conn)

  private_key <- paste(private_key, collapse = "\n")

  openssl::base64_encode(charToRaw(private_key))
}
