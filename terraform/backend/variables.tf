/*
 * Name of backend.
 */
variable "name" {
  type = string
}

/*
 * Set of backend states to maintain.
 */
variable "states" {
  type = list(string)
}
