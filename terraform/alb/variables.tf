/*
 * Task name.
 */
variable "name" {
  type = string
}

/*
 * List of IDs of all subnets.
 */
variable "subnet_ids" {
  type = set(string)
}

/*
 * IDs of the associated security groups.
 */
variable "security_group_ids" {
  type = set(string)
}
