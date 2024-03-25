/*
 * ID of the VPC.
 */
output "vpc_id" {
  value = aws_vpc.vpc.id
}

/*
 * ID of a default subnet.
 */
output "subnet_id" {
  value = aws_subnet.subnet[local.resolved_availability_zone].id
}

/*
 * List of IDs of all subnets.
 */
output "subnet_ids" {
  value = [ for availability_zone in local.resolved_availability_zones : aws_subnet.subnet[availability_zone].id ]
}

/*
 * Map from availability zones to subnet ID.
 */
output "availability_zone_to_subnet_id" {
  value = {
    for availability_zone in local.resolved_availability_zones :
    availability_zone => aws_subnet.subnet[availability_zone].id
  }
}

/*
 * ID of the associated security groups.
 */
output "security_group_ids" {
  value = [
    aws_vpc.vpc.default_security_group_id,
    aws_security_group.allow_egress_to_anywhere.id,
    aws_security_group.allow_ingress_http_from_anywhere.id
  ]
}
