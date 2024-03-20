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
 * ID of the associated security groups.
 */
variable "security_group_ids" {
  type = set(string)
}

/*
 * Report URL for task container.
 */
variable "repository_url" {
  type = string
}
