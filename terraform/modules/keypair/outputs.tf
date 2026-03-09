output "key_pair_name" {
  description = "The name of the created key pair."
  value       = aws_key_pair.main.key_name
}

output "key_pair_id" {
  description = "The ID of the created key pair."
  value       = aws_key_pair.main.id
}

output "key_pair_fingerprint" {
  description = "The fingerprint of the created key pair."
  value       = aws_key_pair.main.fingerprint
}