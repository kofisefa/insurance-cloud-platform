output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id   # must match the resource name in main.tf
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]
}