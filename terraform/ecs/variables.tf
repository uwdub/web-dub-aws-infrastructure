/*
 * Task name.
 */
variable "name" {
  type = string
}

/*
 * Id of the Vpc.
 */
variable "vpc_id" {
  type = string
}

/*
 * List of Ids of all subnets.
 */
variable "subnet_ids" {
  type = set(string)
}

/*
 * Ids of the associated security groups.
 */
variable "security_group_ids" {
  type = set(string)
}

/*
 * Ecr repository for the task.
 */
variable "ecr_repository" {
  type = object({
    name: string
    arn: string
    repository_url: string
  })
}

variable "alb_listener_arn" {
  type = string
}
