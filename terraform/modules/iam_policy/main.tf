resource "aws_iam_policy" "this" {
  name        = var.policy_name
  description = var.policy_description
  policy      = data.aws_iam_policy_document.this.json

  tags = {
    Environment      = var.environment
    ManagedBy        = "Terraform"
    CreatedOrUpdated = timestamp()
  }
}

data "aws_iam_policy_document" "this" {
  dynamic "statement" {
    for_each = var.statements
    content {
      sid       = lookup(statement.value, "sid", null)
      actions   = statement.value.actions
      resources = statement.value.resources
      effect    = lookup(statement.value, "effect", "Allow")

      dynamic "principals" {
        for_each = lookup(statement.value, "principals", [])
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      # CORRECTED: 'condition' is a direct block, not dynamic itself.
      # The 'for_each' for conditions should be on the 'condition' block itself,
      # but it's part of the statement content.
      # If there are conditions, iterate over them and define 'condition' blocks.
      # Simplified this part for the current use case, as your policy doesn't use conditions.
      # For now, let's remove the dynamic conditions block for simplicity if not used.
      # If you NEED conditions, they would look like this (within 'content {}'):
      # condition {
      #   test     = "StringEquals"
      #   variable = "aws:SourceVpc"
      #   values   = ["vpc-12345"]
      # }
      # For now, let's remove this if you are not explicitly using conditions.
      # For a reusable module, passing it as a list of maps for 'condition' arguments is more robust.

      # REVISING THE CONDITIONS BLOCK HANDLING:
      # The 'conditions' argument in a policy document statement is a *list of maps*, not a dynamic block named 'conditions'.
      # Let's adjust the `variables.tf` and `main.tf` to reflect this correctly.
      # Removing the problematic dynamic "conditions" block and preparing for correct format if needed.

      # Since your current S3/SQS list policy does NOT use conditions, the simplest fix is to remove it if it's not needed right now.
      # If you need to add conditions in the future, it would be structured like:
      # condition {
      #   test     = condition.value.test
      #   variable = condition.value.variable
      #   values   = condition.value.values
      # }
      # This needs to be done via a for_each on the condition block itself.
      # The `dynamic` block for `conditions` is incorrect syntax for `aws_iam_policy_document`.

      # Let's revert this to a simpler structure that works correctly without dynamic conditions for now.
      # If you truly need complex conditions, we'll implement it differently.
      # For now, simply remove the `dynamic "conditions"` block from main.tf.
    }
  }
}