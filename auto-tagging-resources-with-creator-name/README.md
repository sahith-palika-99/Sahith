# Auto-tagging resources with the username

Over time, these resources tend to accumulate, and it becomes challenging to determine which ones are still necessary. When we finally realize the magnitude of the resources and the need to evaluate their relevance, it requires bringing in the account owner for a manual review and potential deletion of unnecessary items.

The described task of manually tracking down resources and their creators in AWS can indeed be time-consuming and challenging, especially when relying on limited CloudTrail logs that expire after 90 days.

Considering the discussion, we have created a solution that automatically associates the resource with the IAM username retrieved from CloudTrail.

- Make sure you set the access keys before you deploy the code
