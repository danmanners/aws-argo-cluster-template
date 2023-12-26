# Pulumi Infrastructure Instantiation

Make sure to create an `~/.aws/credentials` file and configure it with the required values.

```ini
[default]
aws_access_key_id = yourAccessKey
aws_secret_access_key = yourSecretKey
region = us-east-1
```

> [!WARNING]
> Your AWS credentials should be treated as sensitive information and should be protected accordingly. Do not post them to the internet, or you risk having your account compromised and having bad actors or "script kiddies" run up your AWS bill, leaving you with the bill!

Next, you'll need to make sure that `pulumi` and `yarn` are installed. On MacOS we can do this by running:

```bash
brew install pulumi yarn
yarn
```

You may also want to set up a functions and aliases in your `.bashrc` or `.zshrc` file like this:

```bash
function plm-pass() {
    read -s var
    export PULUMI_CONFIG_PASSPHRASE=$var
    unset var
}
```

If you're using `fish`, you can use this function

```sh
function plm-pass;
    read -s var;
    set -gx PULUMI_CONFIG_PASSPHRASE $var;
    set -e var;
end
```

Next we'll log into our S3 bucket:

```bash
pulumi login s3://$YourBucketNameHere
```

Finally, we can run our Pulumi code with:

```bash
pulumi up
```
