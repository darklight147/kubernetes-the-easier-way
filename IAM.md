### AWS IAM User Configuration

In order to use this project, you need an AWS IAM user with the necessary permissions configured in your AWS CLI. The IAM user should have the following roles and permissions:

- AmazonEC2FullAccess
- AmazonVPCFullAccess
- AmazonRoute53FullAccess
- AmazonS3FullAccess
- IAMFullAccess

To set up an IAM user with these roles, follow these steps:

1. Sign in to the AWS Management Console and open the IAM console at https://console.aws.amazon.com/iam/.
2. In the navigation pane, choose "Users" and then choose "Add user".
3. Enter a user name, select "Programmatic access" for the access type, and choose "Next: Permissions".
4. On the "Set permissions" page, choose "Attach existing policies directly" and then select the following policies:
   - AmazonEC2FullAccess
   - AmazonVPCFullAccess
   - AmazonRoute53FullAccess
   - AmazonS3FullAccess
   - IAMFullAccess
5. Choose "Next: Tags" and optionally add tags, then choose "Next: Review".
6. Review the user details and choose "Create user".
7. After the user is created, download the CSV file containing the access key ID and secret access key, or copy them from the console.

After creating the IAM user, configure your AWS CLI with the access key ID and secret access key:

```bash
$ aws configure
```

Enter the access key ID and secret access key when prompted.
