# Flurdy CloudFormation Documentation

- [Master](./aws-mirovoy-ref-arch-master.md)
The master stack to run everything.

- [Infrastructure](./aws-mirovoy-ref-arch-infrastructure.md)
A nested stack to set up the core infrastructure, but not the mail-specific
components. Useful if you want to run more than just mail on the same
infrastructure.

- [Mail Master](/.aws-mirovoy-ref-arch-flurdy-mail-master.md)
A nested stack to set up the mail servers (primary, backup, webmail). 
Requres the Infrastructure stack to be set up first.

## Infrastructure Component Templates
- [VPC](./aws-mirovoy-ref-arch-01-newvpc.md)
- [Security Groups](./aws-mirovoy-ref-arch-02-securitygroups.md)
- [Bastion](./aws-mirovoy-ref-arch-03-bastion.md)
- [NAT](./aws-mirovoy-ref-arch-03-nat.md)
- [ALB](./aws-mirovoy-ref-arch-03-publicalb.md)
- [RDS](./aws-mirovoy-ref-arch-03-rds.md)
- [phpMyAdmin](./aws-mirovoy-ref-arch-04-php-my-admin.md)

## Mail Component Templates
- [Mail Storage](./aws-mirovoy-ref-arch-02-mail-storage.md)
- [Mail Servers](./aws-mirovoy-ref-arch-04-mail.md)
- [Roundcube](./aws-mirovoy-ref-arch-05-roundcube.md)
