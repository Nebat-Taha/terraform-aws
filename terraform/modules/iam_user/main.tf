# This resource creates the IAM user itself.
resource "aws_iam_user" "this" {
  name = var.user_name

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    # Adding a timestamp for auditing when the user was created/last managed by Terraform
    CreatedOrUpdated = timestamp()
  }
}

# This resource creates an access key for the IAM user.
# IMPORTANT: Access keys should be handled with extreme care!
# They are sensitive and should never be hardcoded or committed to Git.
# Outputs for these keys are marked as 'sensitive'.
resource "aws_iam_access_key" "this" {
  user = aws_iam_user.this.name
}

# This resource attaches specified policies to the IAM user.
# 'count' is used here to iterate over the list of policy ARNs provided.
resource "aws_iam_user_policy_attachment" "this" {
  count      = length(var.policy_arns) # Create one attachment for each ARN in the list
  user       = aws_iam_user.this.name
  policy_arn = var.policy_arns[count.index] # Reference the current ARN in the loop
}