# Provisioning AWS Infrastructure for Security and Continuous Delivery with Terraform and Elastic Beanstalk

## Preparations

### Create a free new AWS account

Go to: https://aws.amazon.com/free and sign up for a free account.

Tip: If you already have an account and use gmail and want to make a new account for this workshop you can add +<something> before the @ in your email-address. Example: `john.doe+workshop@gmail.com`

### Get your AWS credentials and add them to you keychain (OS X users only)

```
brew install envchain
envchain --set aws AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION
```

### Add your ssh-key to you IAM user

Go to: 

```cat ~/.ssh/id_rsa.pub | pbcopy```

### Install `pass`

[https://www.passwordstore.org/](https://www.passwordstore.org/)

