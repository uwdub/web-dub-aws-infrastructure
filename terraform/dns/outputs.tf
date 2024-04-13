/*
 * Used for manually providing UW with name servers for NS records.
 */
output "dub_uw_edu" {
  value = aws_route53_zone.dub_uw_edu
}

/*
 * Used for manually providing UW with name servers for NS records.
 */
output "dub_washington_edu" {
  value = aws_route53_zone.dub_washington_edu
}
